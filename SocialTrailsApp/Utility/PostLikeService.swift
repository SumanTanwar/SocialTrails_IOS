//
//  PostLikeService.swift
//  SocialTrailsApp
//
//  Created by Admin on 10/26/24.
//

import Foundation
import Firebase
import FirebaseDatabase

class PostLikeService {
    private var reference: DatabaseReference
    private let _collection = "postlike";
    
    init() {
        self.reference = Database.database().reference()
        
    }
}
