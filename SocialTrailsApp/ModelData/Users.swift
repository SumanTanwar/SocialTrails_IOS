//
//  Users.swift
//  SocialTrailsApp
//
//  Created by Admin on 9/29/24.
//

import Foundation
struct Users: Identifiable, Decodable {
    var id: String { userId }
    
    var userId : String
    var username: String
    var email: String
    var bio: String?
    var createdon = Utils.getCurrentDatetime()
    var profilepicture: String?
    var roles: String
    var profiledeleted=false
    var notification = true
    var admindeleted = false
    var suspended = false
    var isactive = true
    var suspendedreason : String?
    var suspendedby : String?
    var admindeletedon : String?
    
    func toDictionary() -> [String: Any] {
           return [
               "userId": userId,
               "username": username,
               "email": email,
               "bio": bio ?? "",
               "createdon": createdon,
               "roles": roles,
               "profiledeleted": profiledeleted,
               "notification": notification,
               "admindeleted": admindeleted,
               "suspended": suspended,
               "suspendedreason": suspendedreason ?? "",
               "suspendedby": suspendedby ?? "",
               "admindeletedon": admindeletedon ?? "",
               "isactive": isactive as Any,
               "profilepicture": profilepicture ?? ""           ]
       }
}
struct SessionUsers :Identifiable,Codable{
    var id : String
    var username : String
    var email : String
    var bio : String
    var notification = true
    var roleType : String
    var profilepicture: String?
}

