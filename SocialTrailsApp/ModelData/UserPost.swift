//
//  UserPost.swift
//  SocialTrailsApp
//
//  Created by Admin on 10/3/24.
//

import Foundation
import UIKit
class UserPost {
    var postId: String = ""
    var userId: String = ""
    var captionText: String = ""
    var createdOn = Date().timeIntervalSince1970
    var updatedOn: String?
    var location: String?
    var postDeleted=false
    var flagged: Bool?
    var moderationStatus: Bool?
    var imageUris: [UIImage]?
    
    
    init( userId: String, captionText: String,imageUris: [UIImage]) {
         
           self.userId = userId
           self.captionText = captionText
           self.createdOn = Date().timeIntervalSince1970
           self.imageUris = imageUris
           self.postDeleted = false
       }
    func toDictionary() -> [String: Any] {
           return [
               "postId": postId,
               "userId": userId,
               "captionText": captionText,
               "createdOn": createdOn,
               "location": location ?? "",
               "postDeleted": postDeleted as Any
               
           ]
       }
}
