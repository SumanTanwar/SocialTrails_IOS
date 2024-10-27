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
    
    init() {
        self.reference = Database.database().reference()
        
    }
    func retrieveComments(postId: String, completion: @escaping ([PostComment]?, Error?) -> Void) {
           reference.child(_collection).queryOrdered(byChild: "postId").queryEqual(toValue: postId)
               .observeSingleEvent(of: .value, with: { (snapshot) in
                   var comments = [PostComment]()
                   
                
                   for child in snapshot.children {
                       if let childSnapshot = child as? DataSnapshot,
                          let dict = childSnapshot.value as? [String: Any] {
                           let postComment = PostComment()
                           postComment.postcommentId = dict["postcommentId"] as? String
                           postComment.postId = dict["postId"] as? String ?? ""
                           postComment.userId = dict["userId"] as? String ?? ""
                           postComment.commenttext = dict["commenttext"] as? String ?? ""
                           postComment.createdon = dict["createdon"] as? String ?? ""
                           postComment.username = dict["username"] as? String
                           postComment.userprofilepicture = dict["userprofilepicture"] as? String
                           comments.append(postComment)
                       }
                   }
                   completion(comments, nil)
                   
               }) { (error) in
                   completion(nil, error)
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
