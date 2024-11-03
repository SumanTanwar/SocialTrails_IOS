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
//                        if let followerIds = userFollow["followerIds"] as? [String] {
//                            allIds.formUnion(followerIds) // Add all follower IDs
//                        }
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

        // Query to find if the current user already has a follow entry
        followRef.queryOrdered(byChild: "userId").queryEqual(toValue: currentUserId).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                for child in snapshot.children {
                    if let ds = child as? DataSnapshot,
                       var userFollow = ds.value as? [String: Any] {
                        
                        // Check if followingIds exists
                        if var followingIds = userFollow["followingIds"] as? [String: Bool] {
                            // Update the followingIds to include the userIdToFollow
                            followingIds[userIdToFollow] = false
                            userFollow["followingIds"] = followingIds
                        } else {
                            // If followingIds doesn't exist, create it and add userIdToFollow
                            userFollow["followingIds"] = [userIdToFollow: false]
                        }

                        // Update the follow entry in the database
                        ds.ref.updateChildValues(userFollow) { error, _ in
                            if let error = error {
                                completion(.failure(error))
                            } else {
                                completion(.success(()))
                            }
                        }
                        return // Exit the loop after updating
                    }
                }
            } else {
                // Create a new follow entry
                let followId = followRef.childByAutoId().key ?? UUID().uuidString
                let newUserFollow: [String: Any] = [
                    "followId": followId,
                    "userId": currentUserId,
                    "followingIds": [userIdToFollow: false],
                    "followerIds": [],
                    "createdOn": Utils.getCurrentDatetime()
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
    func checkPendingForFollowingUser(currentUserId: String, userIdToCheck: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let reference = Database.database().reference()
        
        reference.child(_collection)
            .queryOrdered(byChild: "userId")
            .queryEqual(toValue: userIdToCheck)
            .observeSingleEvent(of: .value) { snapshot in
                
                var hasPendingRequest = false
                
                for child in snapshot.children {
                    if let childSnapshot = child as? DataSnapshot,
                       let userFollow = childSnapshot.value as? [String: Any],
                       let followingIds = userFollow["followingIds"] as? [String: Bool],
                       let isFollowing = followingIds[currentUserId] {
                        
                        if !isFollowing {
                            hasPendingRequest = true
                            break
                        }
                    }
                }
                
                completion(.success(hasPendingRequest))
            } withCancel: { error in
                completion(.failure(error)) // Handle error
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
                                       self.addFollowers(currentUserId: userIdToFollow, userIdToFollow: currentUserId) { result in
                                           completion(result) // Pass the result of addFollowers
                                       }
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
                    print("Current user data found")
                    for child in snapshot.children {
                        if let ds = child as? DataSnapshot,
                           var userFollow = ds.value as? [String: Any] {

                            // Print out current userFollow data
                            print("User Follow Data: \(userFollow)")

                            // Update following IDs
                            if var followingIds = userFollow["followingIds"] as? [String: Bool] {
                                followingIds[userIdToFollow] = true
                                userFollow["followingIds"] = followingIds

                                ds.ref.setValue(userFollow) { error, _ in
                                    if let error = error {
                                        print("Error updating followingIds: \(error)")
                                        completion(.failure(error))
                                    } else {
                                        print("Successfully updated followingIds")
                                        self.addFollowers(currentUserId: currentUserId, userIdToFollow: userIdToFollow) { result in
                                            completion(result) // Pass the result of addFollowers
                                        }
                                    }
                                }
                            } else {
                                print("No followingIds found, initializing")
                                // Initialize if followingIds doesn't exist
                                userFollow["followingIds"] = [userIdToFollow: true]
                                ds.ref.setValue(userFollow) { error, _ in
                                    if let error = error {
                                        completion(.failure(error))
                                    } else {
                                        print("Successfully initialized followingIds")
                                        self.addFollowers(currentUserId: currentUserId, userIdToFollow: userIdToFollow) { result in
                                            completion(result)
                                        }
                                    }
                                }
                            }
                            return // Exit after processing
                        }
                    }
                } else {
                    print("No data found for current user, adding to database")
                    // Create a new UserFollow entry if none exists
                    let followId = self.reference.child(self._collection).childByAutoId().key ?? UUID().uuidString
                    let newUserFollow: [String: Any] = [
                        "followId": followId,
                        "userId": currentUserId,
                        "followingIds": [userIdToFollow: true],
                        "followerIds": []
                    ]
                    self.reference.child(self._collection).child(followId).setValue(newUserFollow) { error, _ in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            print("New UserFollow entry created successfully")
                            self.addFollowers(currentUserId: currentUserId, userIdToFollow: userIdToFollow) { result in
                                completion(result) // Pass the result of addFollowers
                            }
                        }
                    }
                }
            } withCancel: { error in
                print("Error retrieving user data: \(error)")
                completion(.failure(error))
            }
    }

    func followBack(currentUserId: String, userIdToFollow: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let followRef = reference.child(_collection)

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
                                    // Call addFollowers here on success
                                    self.addFollowers(currentUserId: currentUserId, userIdToFollow: userIdToFollow) { result in
                                        completion(result) // Pass the result of addFollowers
                                    }
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
                        // Call addFollowers here since a new follow entry was created
                        self.addFollowers(currentUserId: currentUserId, userIdToFollow: userIdToFollow) { result in
                            completion(result) // Pass the result of addFollowers
                        }
                    }
                }
            }
        } withCancel: { error in
            completion(.failure(error))
        }
    }

    func addFollowers(currentUserId: String, userIdToFollow: String, completion: @escaping (Result<Void, Error>) -> Void) {
        print("hello follow back service button call")
        reference.child(_collection)
            .queryOrdered(byChild: "userId")
            .queryEqual(toValue: userIdToFollow)
            .observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists() {
                    for child in snapshot.children {
                        if let ds = child as? DataSnapshot,
                           var userFollow = ds.value as? [String: Any] {
                            
                            // Ensure followerIds is initialized
                            var followerIds = userFollow["followerIds"] as? [String] ?? []
                            
                            // Check if the current user is already a follower
                            if !followerIds.contains(currentUserId) {
                                followerIds.append(currentUserId)
                                userFollow["followerIds"] = followerIds

                                ds.ref.setValue(userFollow) { error, _ in
                                    if let error = error {
                                        completion(.failure(error))
                                    } else {
                                        completion(.success(())) // Successfully updated followers
                                    }
                                }
                            } else {
                                completion(.success(())) // Already a follower, no need to update
                            }
                            return // Exit after processing
                        }
                    }
                } else {
                    let followId = self.reference.child(self._collection).childByAutoId().key ?? UUID().uuidString
                    let newUserFollow: [String: Any] = [
                        "followId": followId,
                        "userId": userIdToFollow,
                        "followingIds": [],
                        "followerIds":  [currentUserId],
                        "createdOn": Utils.getCurrentDatetime()
                    ]
                    // User does not exist, create a new UserFollow instance
                  
                    self.reference.child(self._collection).child(followId).setValue(newUserFollow) { error, _ in
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
        let currentUserRef = reference.child(_collection).queryOrdered(byChild: "userId").queryEqual(toValue: currentUserId)

        // Step 1: Update the current user's following list
        currentUserRef.observeSingleEvent(of: .value) { snapshot in
            
            guard let child = snapshot.children.allObjects.first as? DataSnapshot,
                  var userFollow = child.value as? [String: Any] else {
                return completion(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Current user not found."])))
            }

            guard var followingIds = userFollow["followingIds"] as? [String: Bool],
                  followingIds[userIdToUnfollow] == true else {
                return completion(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found in following list."])))
            }

            // Remove the user from followingIds
            followingIds.removeValue(forKey: userIdToUnfollow)
            userFollow["followingIds"] = followingIds

            // Update the current user's following list
            child.ref.setValue(userFollow) { error, _ in
                if let error = error {
                    return completion(.failure(error))
                }

                // Step 2: Update the unfollowed user's followers list
                let unfollowedUserRef = self.reference.child(self._collection).queryOrdered(byChild: "userId").queryEqual(toValue: userIdToUnfollow)
                unfollowedUserRef.observeSingleEvent(of: .value) { snapshot in
                    
                    guard let followerChild = snapshot.children.allObjects.first as? DataSnapshot,
                          var userFollowers = followerChild.value as? [String: Any],
                          var followerIds = userFollowers["followerIds"] as? [String] else {
                        return completion(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User to unfollow not found in followers list."])))
                    }

                    // Check if currentUserId exists in followerIds
                    if let index = followerIds.firstIndex(of: currentUserId) {
                        // Remove the current user from followerIds
                        followerIds.remove(at: index)
                    }

                    userFollowers["followerIds"] = followerIds

                    // Update the unfollowed user's followers list
                    followerChild.ref.setValue(userFollowers) { error, _ in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }
                } withCancel: { error in
                    completion(.failure(error))
                }
            }
        } withCancel: { error in
            completion(.failure(error))
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
                    completion(.success([]))
                } else {
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
                           let ids = userFollow["followingIds"] as? [String: Bool] {
                            // Extract keys (user IDs) from the dictionary
                            followingIds.append(contentsOf: ids.keys)
                        }
                    }
                }
                if followingIds.isEmpty {
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
