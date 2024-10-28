//
//  FollowService.swift
//  SocialTrailsApp
//
//  Created by Admin on 10/26/24.
//

import Foundation
import Firebase
import FirebaseDatabase

class FollowService: ObservableObject {
    private var reference: DatabaseReference
    private let _collection = "userfollow"
    private let userService = UserService()

    init() {
        self.reference = Database.database().reference()
    }

    func getFollowAndFollowerIdsByUserId(userId: String, completion: @escaping ([String]?, Error?) -> Void) {
        var allIds = Set<String>() // Use a Set to ensure uniqueness

        reference.child(_collection)
            .queryOrdered(byChild: "userId")
            .queryEqual(toValue: userId)
            .observeSingleEvent(of: .value) { snapshot in
                for child in snapshot.children {
                    if let ds = child as? DataSnapshot,
                       let userFollow = ds.value as? [String: Any] {
                        
                        // Extract following IDs
                        if let followingIds = userFollow["followingIds"] as? [String: Bool] {
                            for (key, value) in followingIds {
                                if value {
                                    allIds.insert(key)
                                    print("following id: \(key)")
                                }
                            }
                        }

                        // Extract follower IDs
                        if let followerIds = userFollow["followerIds"] as? [String] {
                            allIds.formUnion(followerIds) // Add all follower IDs
                        }
                    }
                }

                print("following ids: \(allIds)")
                completion(Array(allIds), nil)
            } withCancel: { error in
                completion(nil, error) 
            }
    }
    
    func sendFollowRequest(currentUserId: String, userIdToFollow: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let followRef = reference.child(_collection)

        followRef.queryOrdered(byChild: "userId").queryEqual(toValue: currentUserId).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                for child in snapshot.children {
                    if let ds = child as? DataSnapshot,
                       var userFollow = ds.value as? [String: Any] {
                        
                        // Update following IDs
                        if var followingIds = userFollow["followingIds"] as? [String: Bool] {
                            followingIds[userIdToFollow] = true // Add user to follow
                            userFollow["followingIds"] = followingIds
                            ds.ref.setValue(userFollow) { error, _ in
                                if let error = error {
                                    completion(.failure(error))
                                } else {
                                    completion(.success(()))
                                }
                            }
                        }
                        return // Exit loop after updating
                    }
                }
            } else {
                // Create a new follow entry
                let followId = followRef.childByAutoId().key ?? UUID().uuidString  
                             let newUserFollow: [String: Any] = [
                                 "userId": currentUserId,
                                 "followingIds": [userIdToFollow: true],
                                 "followerIds": []
                             ]
                followRef.child(followId).setValue(newUserFollow) { error, _ in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
        } withCancel: { error in
            completion(.failure(error))
        }
    }

    }

