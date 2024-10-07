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
    var captiontext: String = ""
    var createdon = Utils.getCurrentDatetime()
    var updatedon: String?
    var location: String?
    var postdeleted=false
    var flagged: Bool?
    var moderationStatus: Bool?
    var imageUris: [UIImage]?
    var latitude: Double?
    var longitude: Double?
    
    
    init( userId: String, captionText: String,imageUris: [UIImage],location: String?,latitude : Double?,longitude : Double?) {
         
           self.userId = userId
           self.captiontext = captionText
        self.createdon = Utils.getCurrentDatetime()
           self.imageUris = imageUris
           self.postdeleted = false
           self.location = location
           self.latitude = latitude
           self.longitude = latitude
       }
    func toDictionary() -> [String: Any] {
           return [
               "postId": postId,
               "userId": userId,
               "captiontext": captiontext,
               "createdon": createdon,
               "location": location ?? "",
               "latitude": latitude ?? "",
               "longitude": longitude ?? "",
               "postdeleted": postdeleted as Any
               
           ]
       }
}
