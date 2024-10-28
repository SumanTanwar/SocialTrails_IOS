//
//  ReportType.swift
//  SocialTrailsApp
//
//  Created by Admin on 10/28/24.
//

import Foundation
enum ReportType: String {
    case user = "user"
    case post = "post"
    
    var reportType: String {
        return self.rawValue
    }
}
