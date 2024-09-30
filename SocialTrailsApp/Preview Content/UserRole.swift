//
//  UserRole.swift
//  SocialTrailsApp
//
//  Created by Admin on 9/29/24.
//

import Foundation

enum UserRole: String {
    case user = "user"
    case moderator = "moderator"
    case admin = "admin"

    var role: String {
        return self.rawValue
    }
}
