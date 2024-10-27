//
//  PostLike.swift
//  SocialTrailsApp
//
//  Created by Admin on 10/26/24.
//

import Foundation
class PostLike {
    var postLikeId: String?
    var postId: String
    var userId: String
    var createdOn: String
    var username: String?
    var profilePicture: String?

    init(postId: String, userId: String) {
        self.postId = postId
        self.userId = userId
        self.createdOn = Utils.getCurrentDatetime()  
    }

}
