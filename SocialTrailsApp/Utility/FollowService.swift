//
//  FollowService.swift
//  SocialTrailsApp
//
//  Created by Admin on 10/26/24.
//

import Foundation
import Firebase
import FirebaseDatabase

class FollowService {
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
}
