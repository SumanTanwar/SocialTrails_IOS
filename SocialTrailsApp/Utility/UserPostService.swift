
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
        reference.child(collectionName).observeSingleEvent(of: .value) { snapshot in
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
                    var mutablePost = post
                    mutablePost.postId = childSnapshot.key
                    tempList.append(mutablePost)
                }
            }

            // Check if tempList is empty
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
                        
                        // Safeguard on user details retrieval
                        self.retrieveUserDetails(userId: post.userId) { userDetails, error in
                            if let userDetails = userDetails {
                                post.username = userDetails.username
                                post.userprofilepicture = userDetails.profilepicture
                            } else if let error = error {
                                print("Error retrieving user details: \(error.localizedDescription)")
                            }

                            self.countCommentsForPost(postId: post.postId) { commentCount, _ in
                                post.commentcount = commentCount ?? 0
                                postList.append(post)
                                pendingRequests.leave()
                            }
                        }
                    case .failure(let error):
                        print("Error fetching images for post \(post.postId): \(error.localizedDescription)")
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

            // Safeguard against nil or empty followedUserIds
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
                completion(postList.isEmpty ? nil : postList, nil)
            }
        }
    }

    func deleteAllLikesForPost(postId: String, completion: @escaping (Result<Void, Error>) -> Void) {
            reference.child("postlike").queryOrdered(byChild: "postId").queryEqual(toValue: postId)
                .observeSingleEvent(of: .value) { snapshot in
                    var deleteTasks: [DatabaseReference] = []

                    for child in snapshot.children {
                        if let likeSnapshot = child as? DataSnapshot {
                            deleteTasks.append(likeSnapshot.ref)
                        }
                    }

                    let dispatchGroup = DispatchGroup()
                    var deleteErrors: [Error] = []

                    for ref in deleteTasks {
                        dispatchGroup.enter()
                        ref.removeValue { error, _ in
                            if let error = error {
                                deleteErrors.append(error)
                            }
                            dispatchGroup.leave()
                        }
                    }

                    dispatchGroup.notify(queue: .main) {
                        if deleteErrors.isEmpty {
                            completion(.success(()))
                        } else {
                            completion(.failure(deleteErrors.first!))
                        }
                    }
                } withCancel: { error in
                    completion(.failure(error))
                }
        }
    func deleteUserPost(postId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // First delete all associated comments
        postCommentService.deleteAllCommentsForPost(postId: postId) { result in
            switch result {
            case .success:
                // Then delete all associated likes
                self.deleteAllLikesForPost(postId: postId) { result in
                    switch result {
                    case .success:
                        // Now delete all associated images
                        self.postImagesService.deleteAllPostImages(postId: postId) { result in
                            switch result {
                            case .success:
                                // Finally, delete the post itself
                                self.reference.child(self.collectionName).child(postId).removeValue { error, _ in
                                    if let error = error {
                                        completion(.failure(error))
                                    } else {
                                        completion(.success(()))
                                    }
                                }
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    func getPostByPostId(postId: String, completion: @escaping (Result<UserPost, Error>) -> Void) {
            reference.child(collectionName).child(postId).observeSingleEvent(of: .value) { snapshot in
                guard let post = try? snapshot.data(as: UserPost.self) else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Post not found"])))
                    return
                }
                post.postId = postId
                
                self.postImagesService.getAllPhotosByPostId(uid: postId) { result in
                    switch result {
                    case .success(let imageUris):
                        post.uploadedImageUris = imageUris
                        completion(.success(post))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            } withCancel: { error in
                completion(.failure(error))
            }
        }
        
        func updateUserPost(post: UserPost, completion: @escaping (Result<Void, Error>) -> Void) {
            post.updatedon = Utils.getCurrentDatetime()
            reference.child(collectionName).child(post.postId).updateChildValues(post.toMapUpdate()) { error, _ in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }

}















