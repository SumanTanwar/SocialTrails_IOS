//
//  UserService.swift
//  SocialTrailsApp
//
//  Created by Admin on 9/29/24.
//

import Foundation
import Firebase
import FirebaseDatabase

class UserManager : ObservableObject{
    
    private var reference: DatabaseReference
    private let _collection = "users";

    init() {
        self.reference = Database.database().reference()
    }
 
    func registerUser(_user: inout Users, completion: @escaping (Bool) -> Void) {
        let newItemKey = reference.child(_collection).childByAutoId().key
        
        if let newItemKey = newItemKey {
            _user.userId = newItemKey
            
            let itemRef = reference.child(_collection).child(_user.userId)
            
            itemRef.setValue(_user.toDictionary()) { error, _ in
                if let error = error {
                    print("Error writing user data: \(error.localizedDescription)")
                    completion(false) // Call completion with false if there's an error
                } else {
                    completion(true) // Call completion with true if the data is successfully written
                }
            }
        } else {
            print("Failed to generate a new item key.")
            completion(false)
        }
    }

}
