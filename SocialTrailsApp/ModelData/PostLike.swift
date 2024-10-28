//
//  PostLike.swift
//  SocialTrailsApp
//
//  Created by Admin on 10/26/24.
//

import Foundation
import Firebase
import FirebaseDatabase
import Foundation
import Firebase
import FirebaseDatabase

import Foundation
import FirebaseDatabase

class PostLike: Identifiable {
        
    var postlikeId: String
    var postId: String
    var userId: String
    var createdon: String
    var username: String?
    var profilepicture: String?

    init(postlikeId: String, postId: String, userId: String) {
        self.postId = postId
        self.userId = userId
        self.postlikeId = postlikeId
        self.createdon = Utils.getCurrentDatetime()
    }
    
    init?(snapshot: DataSnapshot) {
        guard let value = snapshot.value as? [String: Any],
              let postId = value["postId"] as? String,
              let userId = value["userId"] as? String,
              let createdon = value["createdon"] as? String else {
            return nil
        }
        self.postId = postId
        self.userId = userId
        self.postlikeId = snapshot.key
        self.createdon = createdon
    }

    func toDictionary() -> [String: Any] {
        return [
            "postlikeId": postlikeId,
            "createdon": createdon,
            "postId": postId,
            "userId": userId
        ]
    }
}
