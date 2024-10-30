//
//  FollowService.swift
//  SocialTrailsApp
//
//  Created by Admin on 10/26/24.
//

import Foundation
import Firebase
import FirebaseDatabase

protocol DataOperationCallback {
    func onSuccess(followersCount: Int, followingsCount: Int)
    func onFailure(_ error: String)
}

class FollowService: ObservableObject {
    private var reference: DatabaseReference
    private let _collection = "userfollow"
    private let userService = UserService()

    init() {
        self.reference = Database.database().reference()
    }

    func getFollowAndFollowerIdsByUserId(userId: String, completion: @escaping ([String]?, Error?) -> Void) {
        var allIds = Set<String>()

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
        let followRef = reference.child("userFollows")

        // Query to find if the current user already has a follow entry
        followRef.queryOrdered(byChild: "userId").queryEqual(toValue: currentUserId).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                for child in snapshot.children {
                    if let ds = child as? DataSnapshot,
                       var userFollow = ds.value as? [String: Any] {
                        
                        // Update following IDs
                        if var followingIds = userFollow["followingIds"] as? [String: Bool] {
                            followingIds[userIdToFollow] = true
                            userFollow["followingIds"] = followingIds
                            ds.ref.updateChildValues(userFollow) { error, _ in
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
                    "followId": followId,
                    "userId": currentUserId,
                    "followingIds": [userIdToFollow: true],
                    "followerIds": [],
                    "createdOn": ISO8601DateFormatter().string(from: Date())
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

       func checkPendingRequestsForCancel(currentUserId: String, userIdToCheck: String, completion: @escaping (Result<Bool, Error>) -> Void) {
           reference.child(_collection)
               .queryOrdered(byChild: "userId").queryEqual(toValue: currentUserId)
               .observeSingleEvent(of: .value) { snapshot in
                   guard snapshot.exists() else {
                       return completion(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])))
                   }

                   var hasPendingRequest = false
                   for child in snapshot.children {
                       if let ds = child as? DataSnapshot,
                          let userFollow = ds.value as? [String: Any],
                          let followingIds = userFollow["followingIds"] as? [String: Bool] {
                           
                           if followingIds[userIdToCheck] == false {
                               hasPendingRequest = true
                               break
                           }
                       }
                   }
                   completion(.success(hasPendingRequest))
               } withCancel: { error in
                   completion(.failure(error))
               }
       }

       func cancelFollowRequest(currentUserId: String, userIdToUnfollow: String, completion: @escaping (Result<Void, Error>) -> Void) {
           reference.child(_collection)
               .queryOrdered(byChild: "userId").queryEqual(toValue: currentUserId)
               .observeSingleEvent(of: .value) { snapshot in
                   guard snapshot.exists() else {
                       return completion(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])))
                   }

                   for child in snapshot.children {
                       if let ds = child as? DataSnapshot,
                          var userFollow = ds.value as? [String: Any],
                          var followingIds = userFollow["followingIds"] as? [String: Bool],
                          followingIds.keys.contains(userIdToUnfollow) {
                           
                           followingIds.removeValue(forKey: userIdToUnfollow)
                           userFollow["followingIds"] = followingIds
                           
                           ds.ref.setValue(userFollow) { error, _ in
                               if let error = error {
                                   completion(.failure(error))
                               } else {
                                   completion(.success(()))
                               }
                           }
                           return // Exit after updating
                       }
                   }
                   completion(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "No follow request found to cancel."])))
               } withCancel: { error in
                   completion(.failure(error))
               }
       }

       func confirmFollowRequest(currentUserId: String, userIdToFollow: String, completion: @escaping (Result<Void, Error>) -> Void) {
           reference.child(_collection)
               .queryOrdered(byChild: "userId")
               .queryEqual(toValue: userIdToFollow)
               .observeSingleEvent(of: .value) { snapshot in
                   for child in snapshot.children {
                       if let ds = child as? DataSnapshot,
                          var userFollow = ds.value as? [String: Any] {
                           
                           // Update following IDs
                           if var followingIds = userFollow["followingIds"] as? [String: Bool] {
                               followingIds[currentUserId] = true
                               userFollow["followingIds"] = followingIds

                               ds.ref.setValue(userFollow) { error, _ in
                                   if let error = error {
                                       completion(.failure(error))
                                   } else {
                                       completion(.success(()))
                                   }
                               }
                           }
                           return // Exit after updating
                       }
                   }
                   completion(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Follow request not found."])))
               } withCancel: { error in
                   completion(.failure(error))
               }
       }

       func rejectFollowRequest(currentUserId: String, userIdToFollow: String, completion: @escaping (Result<Void, Error>) -> Void) {
           reference.child(_collection)
               .queryOrdered(byChild: "userId")
               .queryEqual(toValue: userIdToFollow)
               .observeSingleEvent(of: .value) { snapshot in
                   for child in snapshot.children {
                       if let ds = child as? DataSnapshot,
                          var userFollow = ds.value as? [String: Any] {
                           
                           // Remove current user from following IDs
                           if var followingIds = userFollow["followingIds"] as? [String: Bool] {
                               followingIds.removeValue(forKey: currentUserId)
                               userFollow["followingIds"] = followingIds

                               ds.ref.setValue(userFollow) { error, _ in
                                   if let error = error {
                                       completion(.failure(error))
                                   } else {
                                       completion(.success(()))
                                   }
                               }
                           }
                           return // Exit after updating
                       }
                   }
                   completion(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Follow request not found."])))
               } withCancel: { error in
                   completion(.failure(error))
               }
       }

       func confirmFollowBack(currentUserId: String, userIdToFollow: String, completion: @escaping (Result<Void, Error>) -> Void) {
           reference.child(_collection)
               .queryOrdered(byChild: "userId")
               .queryEqual(toValue: currentUserId)
               .observeSingleEvent(of: .value) { snapshot in
                   if snapshot.exists() {
                       for child in snapshot.children {
                           if let ds = child as? DataSnapshot,
                              var userFollow = ds.value as? [String: Any] {

                               // Update following IDs
                               if var followingIds = userFollow["followingIds"] as? [String: Bool] {
                                   followingIds[userIdToFollow] = true
                                   userFollow["followingIds"] = followingIds

                                   ds.ref.setValue(userFollow) { error, _ in
                                       if let error = error {
                                           completion(.failure(error))
                                       } else {
                                           completion(.success(())) // Follow back confirmed
                                       }
                                   }
                               }
                               return // Exit after processing
                           }
                       }
                   } else {
                       // Create a new UserFollow entry if none exists
                       let followId = self.reference.child(self._collection).childByAutoId().key ?? UUID().uuidString
                       let newUserFollow: [String: Any] = [
                           "userId": currentUserId,
                           "followingIds": [userIdToFollow: true],
                           "followerIds": []
                       ]
                       self.reference.child(self._collection).child(followId).setValue(newUserFollow) { error, _ in
                           if let error = error {
                               completion(.failure(error))
                           } else {
                               completion(.success(())) // Follow back confirmed with new entry
                           }
                       }
                   }
               } withCancel: { error in
                   completion(.failure(error))
               }
       }

       func followBack(currentUserId: String, userIdToFollow: String, completion: @escaping (Result<Void, Error>) -> Void) {
           reference.child(_collection)
               .queryOrdered(byChild: "userId")
               .queryEqual(toValue: userIdToFollow)
               .observeSingleEvent(of: .value) { snapshot in
                   if snapshot.exists() {
                       for child in snapshot.children {
                           if let ds = child as? DataSnapshot,
                              var userFollow = ds.value as? [String: Any] {

                               // Update follower list
                               if var followerIds = userFollow["followerIds"] as? [String] {
                                   followerIds.append(currentUserId)
                                   userFollow["followerIds"] = followerIds

                                   ds.ref.setValue(userFollow) { error, _ in
                                       if let error = error {
                                           completion(.failure(error))
                                       } else {
                                           // Confirm the follow back after adding the follower
                                           self.confirmFollowBack(currentUserId: currentUserId, userIdToFollow: userIdToFollow, completion: completion)
                                       }
                                   }
                               }
                               return // Exit after processing
                           }
                       }
                   } else {
                       // User does not exist, create a new UserFollow instance
                       let newUserFollow: [String: Any] = [
                           "userId": userIdToFollow,
                           "followingIds": [:],
                           "followerIds": [currentUserId]
                       ]

                       // Set the followId as a new unique key
                       let newFollowId = self.reference.child(self._collection).childByAutoId().key ?? UUID().uuidString
                       self.reference.child(self._collection).child(newFollowId).setValue(newUserFollow) { error, _ in
                           if let error = error {
                               completion(.failure(error))
                           } else {
                               completion(.success(())) // Follow relationship created
                           }
                       }
                   }
               } withCancel: { error in
                   completion(.failure(error))
               }
       }

       func checkIfFollowed(currentUserId: String, userIdToCheck: String, completion: @escaping (Result<Bool, Error>) -> Void) {
           reference.child(_collection)
               .queryOrdered(byChild: "userId")
               .queryEqual(toValue: userIdToCheck)
               .observeSingleEvent(of: .value) { snapshot in
                   var isFollowed = false
                   for child in snapshot.children {
                       if let ds = child as? DataSnapshot,
                          let userFollow = ds.value as? [String: Any],
                          let followingIds = userFollow["followingIds"] as? [String: Bool] {
                           if followingIds[currentUserId] == true {
                               isFollowed = true
                               break
                           }
                       }
                   }
                   completion(.success(isFollowed))
               } withCancel: { error in
                   completion(.failure(error)) // Handle error
               }
       }

       func unfollowUser(currentUserId: String, userIdToUnfollow: String, completion: @escaping (Result<Void, Error>) -> Void) {
           reference.child(_collection)
               .queryOrdered(byChild: "userId")
               .queryEqual(toValue: currentUserId)
               .observeSingleEvent(of: .value) { snapshot in
                   for child in snapshot.children {
                       if let ds = child as? DataSnapshot,
                          var userFollow = ds.value as? [String: Any],
                          let followingIds = userFollow["followingIds"] as? [String: Bool],
                          followingIds[userIdToUnfollow] == true {
                           
                           // Remove the user from followingIds
                           var updatedFollowingIds = followingIds
                           updatedFollowingIds.removeValue(forKey: userIdToUnfollow)
                           userFollow["followingIds"] = updatedFollowingIds
                           
                           ds.ref.setValue(userFollow) { error, _ in
                               if let error = error {
                                   completion(.failure(error))
                               } else {
                                   completion(.success(())) // Successfully unfollowed
                               }
                           }
                           return // Exit after processing the user
                       }
                   }
                   completion(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found in following list."])))
               } withCancel: { error in
                   completion(.failure(error)) // Handle error
               }
       }

       func checkUserFollowStatus(currentUserId: String, userIdToCheck: String, completion: @escaping (Result<Bool, Error>) -> Void) {
           reference.child(_collection)
               .queryOrdered(byChild: "userId")
               .queryEqual(toValue: userIdToCheck)
               .observeSingleEvent(of: .value) { snapshot in
                   var isFollowed = false
                   for child in snapshot.children {
                       if let ds = child as? DataSnapshot,
                          let userFollow = ds.value as? [String: Any],
                          let followingIds = userFollow["followingIds"] as? [String: Bool] {
                           if followingIds[currentUserId] == true {
                               isFollowed = true
                               break
                           }
                       }
                   }
                   completion(.success(isFollowed))
               } withCancel: { error in
                   completion(.failure(error)) // Handle error
               }
       }
    func getFollowCounts(for userId: String, callback: DataOperationCallback) {
           var followersCount = 0
           var followingsCount = 0
           
           let group = DispatchGroup()

           // Fetch follower count
           group.enter()
           getFollowersCount(for: userId) { count, error in
               if let error = error {
                   callback.onFailure("Error fetching followers: \(error)")
                   group.leave()
                   return
               }
               followersCount = count
               group.leave()
           }

           // Fetch following count
           group.enter()
           getFollowingsCount(for: userId) { count, error in
               if let error = error {
                   callback.onFailure("Error fetching following: \(error)")
                   group.leave()
                   return
               }
               followingsCount = count
               group.leave()
           }

           group.notify(queue: .main) {
               callback.onSuccess(followersCount: followersCount, followingsCount: followingsCount)
           }
       }
       
       // Modify the existing follower and following count methods
    func getFollowersCount(for userId: String, completion: @escaping (Int, String?) -> Void) {
        print("userid : \(userId)")
        reference.child(_collection)
            .queryOrdered(byChild: "userId")
            .queryEqual(toValue: userId)
            .observeSingleEvent(of: .value) { snapshot in
                var count = 0
                
                // Check if snapshot has children
                if snapshot.hasChildren() {
                    for child in snapshot.children {
                        if let childSnapshot = child as? DataSnapshot,
                           let userFollow = childSnapshot.value as? [String: Any] {
                            
                            // Extract follower IDs
                            if let followerIds = userFollow["followerIds"] as? [String] {
                                count += followerIds.count // Increment count by the number of followers
                                print("Follower IDs: \(followerIds)")
                            }
                        }
                    }
                }

                print("count : \(count)")
                completion(count, nil)
            } withCancel: { error in
                completion(0, "Error fetching followers count: \(error.localizedDescription)")
            }
    }


    func getFollowingsCount(for userId: String, completion: @escaping (Int, String?) -> Void) {
        reference.child(_collection)
            .queryOrdered(byChild: "userId")
            .queryEqual(toValue: userId)
            .observeSingleEvent(of: .value) { snapshot in
                var count = 0
                
                // Check if snapshot has children
                if snapshot.hasChildren() {
                    for child in snapshot.children {
                        if let childSnapshot = child as? DataSnapshot,
                           let userFollow = childSnapshot.value as? [String: Any],
                           let followingIds = userFollow["followingIds"] as? [String: Bool] {
                            for (key, value) in followingIds {
                                if value {
                                    count += 1 // Use += instead of ++
                                    print("Following id: \(key)")
                                }
                            }
                        }
                    }
                }

                print("Count of followings: \(count)")
                completion(count, nil)
            } withCancel: { error in
                completion(0, "Error fetching followings count: \(error.localizedDescription)")
            }
    }


    func getFollowersDetails(userId: String, completion: @escaping (Result<[Users], Error>) -> Void) {
        reference.child(_collection)
            .queryOrdered(byChild: "userId")
            .queryEqual(toValue: userId)
            .observeSingleEvent(of: .value) { snapshot in
                var followerIds: [String] = []
                
                // Check if snapshot has children
                if snapshot.hasChildren() {
                    for child in snapshot.children {
                        if let childSnapshot = child as? DataSnapshot,
                           let userFollow = childSnapshot.value as? [String: Any],
                           let ids = userFollow["followerIds"] as? [String] {
                            followerIds.append(contentsOf: ids)
                        }
                    }
                }

                if followerIds.isEmpty {
                    print("isempty")
                    // If no follower IDs, return an empty array
                    completion(.success([]))
                } else {
                    print("no empty")
                    self.fetchUserDetails(followerIds: followerIds, completion: completion)
                }
            } withCancel: { error in
                completion(.failure(error))
            }
    }


    func getFollowingDetails(userId: String, completion: @escaping (Result<[Users], Error>) -> Void) {
        reference.child(_collection)
            .queryOrdered(byChild: "userId")
            .queryEqual(toValue: userId)
            .observeSingleEvent(of: .value) { snapshot in
                var followingIds: [String] = []
                
                // Check if snapshot has children
                if snapshot.hasChildren() {
                    for child in snapshot.children {
                        if let childSnapshot = child as? DataSnapshot,
                           let userFollow = childSnapshot.value as? [String: Any],
                           let followingIdsDict = userFollow["followingIds"] as? [String: Bool] {
                            for (id, isFollowing) in followingIdsDict {
                                if isFollowing {
                                    followingIds.append(id)
                                }
                            }
                        }
                    }
                }

                if followingIds.isEmpty {
                    // If no following IDs, return an empty array
                    completion(.success([]))
                } else {
                    self.fetchUserDetails(followerIds: followingIds, completion: completion)
                }
            } withCancel: { error in
                completion(.failure(error))
            }
    }

    private func fetchUserDetails(followerIds: [String], completion: @escaping (Result<[Users], Error>) -> Void) {
        var users: [Users] = []
        let dispatchGroup = DispatchGroup()

        for id in followerIds {
            dispatchGroup.enter()
            
            self.retrieveUserDetails(userId: id) { userDetails, error in
                if let userDetails = userDetails {
                    print("User detail added for userId: \(id)")
                    users.append(userDetails)
                } else if let error = error {
                    print("Error retrieving user details for userId: \(id): \(error.localizedDescription)")
                }
                dispatchGroup.leave() // Move this line inside the completion handler
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(.success(users))
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
    
   }
