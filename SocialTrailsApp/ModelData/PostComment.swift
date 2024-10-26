//
//  PostComment.swift
//  SocialTrailsApp
//
//  Created by Admin on 10/24/24.
//

import Foundation
class PostComment {
    var postcommentId: String?
    var postId: String
    var userId: String
    var commenttext: String
    var createdon: String
    var username: String?
    var userprofilepicture: String?
    
    init()
    {
        self.postId = ""
        self.userId = ""
        self.commenttext = ""
        self.createdon = Utils.getCurrentDatetime()
    }
    init(postId: String, userId: String, commenttext: String) {
        self.postId = postId
        self.userId = userId
        self.commenttext = commenttext
        self.createdon = Utils.getCurrentDatetime()
    }
    func toDictionary() -> [String: Any] {
            return [
                "postcommentId": postcommentId ?? "",
                "postId": postId,
                "userId": userId,
                "commenttext": commenttext,
                "createdon": createdon,
            ]
        }
}
