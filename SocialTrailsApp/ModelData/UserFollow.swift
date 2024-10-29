//
//  UserFollow.swift
//  SocialTrailsApp
//
//  Created by Admin on 10/26/24.
//

import Foundation
class UserFollow {
    var followId: String?
    var userId: String
    var followerIds: [String]
    var followingIds: [String: Bool]
    var createdOn: String
    
    init() {
        self.followId = UUID().uuidString
        self.userId = ""
        self.createdOn = Utils.getCurrentDatetime() 
        self.followingIds = [:]
        self.followerIds = []
    }
    
    init(userId: String) {
        self.followId = UUID().uuidString
        self.userId = userId
        self.createdOn = Utils.getCurrentDatetime()
        self.followingIds = [:]
        self.followerIds = []
    }
    func toDictionary() -> [String: Any] {
           return [
               "followId": followId,
               "userId": userId,
               "followerIds": followerIds,
               "followingIds": followingIds,
               "createdOn": createdOn
           ]
       }
    func addFollower(id: String) {
          followerIds.append(id)
      }

      func removeFollower(id: String) {
          followerIds.removeAll { $0 == id }
      }

      func addFollowing(id: String) {
          followingIds[id] = true
      }

      func removeFollowing(id: String) {
          followingIds.removeValue(forKey: id)
      }
    
}
