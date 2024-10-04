//
//  PostImages.swift
//  SocialTrailsApp
//
//  Created by Admin on 10/3/24.
//

import Foundation
import UIKit

class  PostImages {
    var imageId: String?
    var postId: String
    var imagePath: String
    var order : Int
    
    init( postId: String, imagePath: String, order: Int) {
            self.postId = postId
            self.imagePath = imagePath
            self.order = order
    }
    
    func toDictionary() -> [String: Any] {
           return [
               "imageId": imageId ?? UUID(),
               "postId": postId,
               "imagePath": imagePath,
               "order": order as Any
               
           ]
       }
    
}
