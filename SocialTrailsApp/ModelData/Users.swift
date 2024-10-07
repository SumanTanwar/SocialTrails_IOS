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
    var createdon = Date().timeIntervalSince1970
    var profilepicture: String?
    var roles: String
    var profiledeleted=false
    var notification = true
    var admindeleted = false
    var suspended = false
    var isactive = true
    
    func toDictionary() -> [String: Any] {
           return [
               "userId": userId,
               "username": username,
               "email": email,
               "createdon": createdon,
               "roles": roles,
               "profiledeleted": profiledeleted,
               "notification": notification,
               "admindeleted": admindeleted,
               "suspended": suspended,
               "isactive": isactive as Any
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
