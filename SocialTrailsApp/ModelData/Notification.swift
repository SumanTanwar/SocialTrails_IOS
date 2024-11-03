//
//  Notification.swift
//  SocialTrailsApp
//
//  Created by Admin on 11/2/24.
//

import Foundation
import FirebaseDatabaseInternal


class Notification: Identifiable {
    var notificationId: String?
    var notifyto: String
    var type: String
    var message: String
    var relatedId: String
    var createdon: String
    var notifyBy: String
    var username: String?
    var userProfilePicture: String?

    // Initializer without username and userProfilePicture
    init(notifyto: String, notifyBy: String, type: String, message: String, relatedId: String) {
        self.notifyto = notifyto
        self.notifyBy = notifyBy
        self.type = type
        self.message = message
        self.relatedId = relatedId
        self.createdon = Utils.getCurrentDatetime()
    }
    
    // Dictionary representation
    func toDictionary() -> [String: Any] {
        return [
            "notificationId": notificationId as Any,
            "notifyto": notifyto,
            "type": type,
            "message": message,
            "relatedId": relatedId,
            "createdon": createdon,
            "notifyBy": notifyBy
        ]
    }

    // Initialize from DataSnapshot (Firebase)
    convenience init?(snapshot: DataSnapshot) {
        guard let value = snapshot.value as? [String: Any] else {
            return nil
        }
        self.init(
            notifyto: value["notifyto"] as? String ?? "",
            notifyBy: value["notifyBy"] as? String ?? "",
            type: value["type"] as? String ?? "",
            message: value["message"] as? String ?? "",
            relatedId: value["relatedId"] as? String ?? ""
        )
        self.notificationId = snapshot.key
        self.createdon = value["createdon"] as? String ?? Utils.getCurrentDatetime()
        
      
        self.username = value["username"] as? String
        self.userProfilePicture = value["userProfilePicture"] as? String
    }
}

