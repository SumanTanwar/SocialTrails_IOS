//
//  ReportStatus.swift
//  SocialTrailsApp
//
//  Created by Admin on 10/28/24.
//

import Foundation
enum ReportStatus: String {
    case pending = "pending"
    case reviewing = "reviewing"
    case actioned = "actioned"
    
    var reportStatus: String {
        return self.rawValue
    }
}
