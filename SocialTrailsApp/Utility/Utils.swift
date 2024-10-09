//
//  Utils.swift
//  SocialTrailsApp
//
//  Created by Admin on 9/29/24.
//

import Foundation
import SwiftUI

struct Utils {
    static func isValidEmail(_ email: String) -> Bool {
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    static func isPasswordValid(_ password: String) -> Bool {
        
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d).{6,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
    static func getCurrentDatetime() -> String {
              let dateFormatter = DateFormatter()
              dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
              dateFormatter.locale = Locale.current
              return dateFormatter.string(from: Date())
          }
    
    //MARK: font size
    static let fontSize8: CGFloat = 8
    static let fontSize16: CGFloat = 16
    static let fontSize20: CGFloat = 20
    static let fontSize24: CGFloat = 24
    static let fontSize28: CGFloat = 28
    
    //MARK: Color
    static let blackListColor: Color = .black
   
    
}
