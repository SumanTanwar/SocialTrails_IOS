//
//  Users.swift
//  SocialTrailsApp
//
//  Created by Admin on 9/29/24.
//

import Foundation
struct Users {
    var userId : String
    var username: String
    var email: String
    var createdOn = Date().timeIntervalSince1970
    var profilepicture: String?
    var roles: String
    var profiledeleted=false
    var notification = true
    var admindeleted = false
    var suspended = false
    var isActive = true
    
    func toDictionary() -> [String: Any] {
           return [
               "userId": userId,
               "username": username,
               "email": email,
               "createdOn": createdOn,
               "roles": roles,
               "profiledeleted": profiledeleted,
               "notification": notification,
               "admindeleted": admindeleted,
               "suspended": suspended,
               "isActive": isActive as Any
           ]
       }
}
struct SessionUsers :Identifiable,Codable{
    var id : String
    var username : String
    var email : String
    var notification = true
    var roleType : String
}
