//
//  UserService.swift
//  SocialTrailsApp
//
//  Created by Admin on 9/29/24.
//

import Foundation
import Firebase
import FirebaseDatabase

class UserService : ObservableObject{
    
    private var reference: DatabaseReference
    private let _collection = "users";

    init() {
        self.reference = Database.database().reference()
    }
 
    func registerUser(_user:  Users, completion: @escaping (Bool) -> Void) {
       
            
            let itemRef = reference.child(_collection).child(_user.userId)
            
            itemRef.setValue(_user.toDictionary()) { error, _ in
                if let error = error {
                    print("Error writing user data: \(error.localizedDescription)")
                    completion(false) // Call completion with false if there's an error
                } else {
                    completion(true) // Call completion with true if the data is successfully written
                }
            }
        }
    func fetchUserByUserID(withID id: String, completion: @escaping (SessionUsers?) -> Void) {
        let usersRef = reference.child(_collection)
        
        usersRef.child(id)
            .observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists() {
                    print("Snapshot exists: \(snapshot)")
                    
                    if let userData = snapshot.value as? [String: Any] {
                        print("data parse started")
                       
                        let username = userData["username"] as? String ?? ""
                        let email = userData["email"] as? String ?? ""
                        let roles = userData["roles"] as? String ?? ""
                        let notification = userData["notification"] as? Bool ?? true
                        
                       
                        let user = SessionUsers(id: id,
                                                username: username,
                                                email: email,
                                                notification: notification, roleType: roles)
                        
                        completion(user)
                    } else {
                        print("Failed to parse user data for id: \(id)")
                        completion(nil)
                    }
                } else {
                    print("No user found for id: \(id)")
                    completion(nil)
                }
            }
    }


}
