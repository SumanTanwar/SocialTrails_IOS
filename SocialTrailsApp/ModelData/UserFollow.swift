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
        self.userId = ""
        self.createdOn = Utils.getCurrentDatetime() 
        self.followingIds = [:]
        self.followerIds = []
    }
    
    init(userId: String) {
        self.userId = userId
        self.createdOn = Utils.getCurrentDatetime()
        self.followingIds = [:]
        self.followerIds = []
    }
}
