//
//  PostLikeService.swift
//  SocialTrailsApp
//
//  Created by Admin on 10/26/24.
//

import Foundation
import Firebase
import FirebaseDatabase

class PostLikeService {
    private var reference: DatabaseReference
    private let collectionName = "postlike"
    private let userPostService = UserPostService()
    private let userService = UserService()

    init() {
        reference = Database.database().reference()
    }
    
    func likeAndUnlikePost(postId: String, userId: String, completion: @escaping (Result<LikeResult, Error>) -> Void) {
        getPostLikeByUserAndPostId(postId: postId, userId: userId) { result in
            switch result {
            case .success(let existingPostLike):
                self.reference.child(self.collectionName).child(existingPostLike.postlikeId).removeValue { error, _ in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    self.userPostService.updateLikeCount(postId: postId, change: -1) { result in
                        switch result {
                        case .success(let count):
                            completion(.success(LikeResult(count: count, isliked: false)))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                }
            case .failure:
                if let newItemKey = self.reference.child(self.collectionName).childByAutoId().key {
                    let model = PostLike(postlikeId: newItemKey, postId: postId, userId: userId)
                    self.reference.child(self.collectionName).child(newItemKey).setValue(model.toDictionary()) { error, _ in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        self.userPostService.updateLikeCount(postId: postId, change: 1) { result in
                            switch result {
                            case .success(let count):
                                completion(.success(LikeResult(count: count, isliked: true)))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    }
                }
            }
        }
    }

    func getPostLikeByUserAndPostId(postId: String, userId: String, completion: @escaping (Result<PostLike, Error>) -> Void) {
        reference.child(collectionName).observeSingleEvent(of: .value) { snapshot in
            for userSnapshot in snapshot.children {
                if let likeSnapshot = userSnapshot as? DataSnapshot,
                   let postLike = PostLike(snapshot: likeSnapshot),
                   postLike.userId == userId && postLike.postId == postId {
                    completion(.success(postLike))
                    return
                }
            }
            completion(.failure(NSError(domain: "PostLikeService", code: 404, userInfo: [NSLocalizedDescriptionKey: "No matching like found."])))
        }
    }

    func getLikesForPost(postId: String, completion: @escaping (Result<[PostLike], Error>) -> Void) {
        var likesWithUsers: [PostLike] = []

        reference.child(collectionName).queryOrdered(byChild: "postId").queryEqual(toValue: postId).observeSingleEvent(of: .value) { (snapshot : DataSnapshot) in
            for likeSnapshot in snapshot.children {
                if let likeSnapshot = likeSnapshot as? DataSnapshot,
                   let postLike = PostLike(snapshot: likeSnapshot) {
                    self.userService.getUserByID(uid: postLike.userId) { result in
                        switch result {
                        case .success(let user):
                            postLike.username = user.username
                            postLike.profilepicture = user.profilepicture
                            likesWithUsers.append(postLike)
                            if likesWithUsers.count == snapshot.childrenCount {
                                completion(.success(likesWithUsers))
                            }
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                }
            }
            if likesWithUsers.isEmpty {
                completion(.success(likesWithUsers))
            }
        }
    }

    func removeLike(postlikeId: String, postId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        reference.child(collectionName).child(postlikeId).removeValue { error, _ in
            if let error = error {
                completion(.failure(error))
                return
            }
            self.userPostService.updateLikeCount(postId: postId, change: -1) { result in
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}
