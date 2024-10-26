
//
//  UserPostService.swift
//  SocialTrailsApp
//
//  Created by Admin on 10/3/24.
//

import Foundation
import FirebaseDatabase

class UserPostService: ObservableObject {

    private var reference: DatabaseReference
    private let collectionName = "post"
    private let postImagesService = PostImagesService()
    private let postCommentService = PostCommentService()
    private let userService = UserService()
    private let followService = FollowService()
    
    init() {
        reference = Database.database().reference()
    }

    func createPost(userPost: UserPost, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let newItemKey = reference.child(collectionName).childByAutoId().key else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to generate a unique key."])))
            return
        }
        
        userPost.postId = newItemKey
        
        reference.child(collectionName).child(newItemKey).setValue(userPost.toDictionary()) { error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                if let imageUris = userPost.imageUris {
                    self.postImagesService.uploadImages(postId: newItemKey, imageUris: imageUris) { result in
                        switch result {
                        case .success:
                            completion(.success(()))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No images to upload."])))
                }
            }
        }
    }
    


    func getAllUserPosts(userId: String, completion: @escaping (Result<[UserPost], Error>) -> Void) {
        

        reference.child(collectionName).observe(.value) { snapshot in
           

            guard let snapshot = snapshot as? DataSnapshot else {
                completion(.failure(NSError(domain: "DataSnapshotError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not cast snapshot to DataSnapshot."])))
                return
            }
            print("snapshot count \(snapshot.childrenCount)")
            var postList: [UserPost] = []
            var tempList: [UserPost] = []
      
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let post = try? childSnapshot.data(as: UserPost.self) {
                    if post.userId == userId
                        {
                        let mutablePost = post
                        mutablePost.postId = childSnapshot.key
                        tempList.append(mutablePost)
                    }
                }
            }

            if tempList.isEmpty {
                completion(.success(postList.sorted(by: { $0.createdon > $1.createdon })))
                return
            }

            let pendingRequests = DispatchGroup()

            for post in tempList {
                pendingRequests.enter()
                self.postImagesService.getAllPhotosByPostId(uid: post.postId) { result in
                    switch result {
                    case .success(let imageUrls):
                        let mutablePost = post
                        mutablePost.uploadedImageUris = imageUrls
                        postList.append(mutablePost)
                    case .failure(let error):
                        // Handle the error if needed, for example, log it
                        print("Error fetching photos for post ID \(post.postId): \(error.localizedDescription)")
                    }
                    pendingRequests.leave()
                }
            }

            pendingRequests.notify(queue: .main) {
                completion(.success(postList.sorted(by: { $0.createdon > $1.createdon })))
            }
        }
    }
    func retrieveUserDetails(userId: String, completion: @escaping (Users?, Error?) -> Void) {
        userService.getUserByID(uid: userId) { result in
            switch result {
            case .success(let user):
                completion(user, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }


       
        func countCommentsForPost(postId: String, completion: @escaping (Int?, Error?) -> Void) {
            postCommentService.retrieveComments(postId: postId) { comments, error in
                if let comments = comments {
                    completion(comments.count, nil)
                } else {
                    completion(nil, error)
                }
            }
        }
    func getAllUserPostDetail(userId: String, completion: @escaping ([UserPost]?, Error?) -> Void) {
            reference.child(collectionName).observe(.value) { snapshot in
                guard let snapshot = snapshot as? DataSnapshot else {
                    completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not retrieve data"]))
                    return
                }

                var postList: [UserPost] = []
                var tempList: [UserPost] = []

                for child in snapshot.children {
                    if let childSnapshot = child as? DataSnapshot,
                       let post = try? childSnapshot.data(as: UserPost.self),
                       post.userId == userId {
                        let mutablePost = post
                        mutablePost.postId = childSnapshot.key
                        tempList.append(mutablePost)
                    }
                }

                if tempList.isEmpty {
                    completion([], nil)
                    return
                }

                let pendingRequests = DispatchGroup()

                for post in tempList {
                    pendingRequests.enter()

                    self.postImagesService.getAllPhotosByPostId(uid: post.postId) { result in
                        switch result {
                        case .success(let imageUrls):
                            print("post : \(post.postId) and images \(imageUrls.count)")
                            post.uploadedImageUris = imageUrls

                            self.retrieveUserDetails(userId: post.userId) { userDetails, _ in
                                if let userDetails = userDetails {
                                    post.username = userDetails.username
                                    post.userprofilepicture = userDetails.profilepicture
                                }

                                self.countCommentsForPost(postId: post.postId) { commentCount, _ in
                                    post.commentcount = commentCount ?? 0
                                    postList.append(post)
                                    pendingRequests.leave()
                                }
                            }
                        case .failure:
                            postList.append(post)
                            pendingRequests.leave()
                        }
                    }
                }

                // Notify when all async tasks are done
                pendingRequests.notify(queue: .main) {
                    postList.sort { $0.createdon > $1.createdon }
                    completion(postList, nil)
                }
            }
        }
    
    func retrievePostsForFollowedUsers(currentUserId: String, completion: @escaping ([UserPost]?, Error?) -> Void) {
        followService.getFollowAndFollowerIdsByUserId(userId: currentUserId) { followedUserIds, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let followedUserIds = followedUserIds, !followedUserIds.isEmpty else {
                print("No followed users")
                completion([], nil)
                return
            }

            print("Follower List: \(followedUserIds)")

            var postList: [UserPost] = []
            let pendingRequests = DispatchGroup()

            for userId in followedUserIds {
                pendingRequests.enter()
                self.getAllUserPostDetail(userId: userId) { posts, error in
                    if let posts = posts {
                        postList.append(contentsOf: posts)
                    } else if let error = error {
                        print("Error fetching posts for user \(userId): \(error.localizedDescription)")
                    }
                    pendingRequests.leave()
                }
            }

            pendingRequests.notify(queue: .main) {
                completion(postList, nil) 
            }
        }
    }
}















