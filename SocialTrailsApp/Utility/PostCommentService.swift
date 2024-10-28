//
//  PostCommentService.swift
//  SocialTrailsApp
//
//  Created by Admin on 10/24/24.
//

import Foundation
import Firebase
import FirebaseDatabase

class PostCommentService {
    private var reference: DatabaseReference
    private let _collection = "postcomment";
    private let userService = UserService()
    
    init() {
        self.reference = Database.database().reference()
        
    }
    func addPostComment(data: PostComment, completion: @escaping (Result<Void, Error>) -> Void) {
            let newItemKey = reference.child(_collection).childByAutoId().key
            data.postcommentId = newItemKey
            
        
        reference.child(_collection).child(newItemKey!).setValue(data.toDictionary()) { error, _ in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    
       func removePostComment(commentId: String, completion: @escaping (Result<Void, Error>) -> Void) {
           reference.child(_collection).child(commentId).removeValue { error, _ in
               if let error = error {
                   completion(.failure(error))
               } else {
                   completion(.success(()))
               }
           }
       }
       
    func retrieveComments(postId: String, completion: @escaping (Result<[PostComment], Error>) -> Void) {
            reference.child(_collection).queryOrdered(byChild: "postId").queryEqual(toValue: postId)
            .observeSingleEvent(of: .value) { (snapshot  : DataSnapshot)in
                    var comments = [PostComment]()
                    let dispatchGroup = DispatchGroup()
                    
                    for child in snapshot.children {
                        if let childSnapshot = child as? DataSnapshot,
                           let dict = childSnapshot.value as? [String: Any] {
                            let postComment = PostComment()
                            postComment.postcommentId = dict["postcommentId"] as? String
                            postComment.postId = dict["postId"] as? String ?? ""
                            postComment.userId = dict["userId"] as? String ?? ""
                            postComment.commenttext = dict["commenttext"] as? String ?? ""
                            postComment.createdon = dict["createdon"] as? String ?? ""
                            comments.append(postComment)
                            
                            dispatchGroup.enter()
                            self.userService.getUserByID(uid: postComment.userId) { result in
                                                    switch result {
                                                    case .success(let user):
                                                        postComment.username = user.username
                                                        postComment.userprofilepicture = user.profilepicture
                                                    case .failure:
                                                        
                                                        break
                                                    }
                                                    dispatchGroup.leave()
                                                }
                        }
                    }
                    
                    dispatchGroup.notify(queue: .main) {
                        completion(.success(comments))
                    }
                } withCancel: { error in
                    completion(.failure(error))
                }
    }
    
    func deleteAllCommentsForPost(postId: String, completion: @escaping (Result<Void, Error>) -> Void) {
            reference.child(_collection)
                .queryOrdered(byChild: "postId")
                .queryEqual(toValue: postId)
                .observeSingleEvent(of: .value) { snapshot in
                    var deleteTasks: [DatabaseReference] = []

                    for childSnapshot in snapshot.children {
                        if let commentSnapshot = childSnapshot as? DataSnapshot {
                            deleteTasks.append(commentSnapshot.ref)
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
}
