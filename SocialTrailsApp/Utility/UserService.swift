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
                        let isProfileDeleted = userData["profiledeleted"] as? Bool ?? false
                        let isAdminDeleted = userData["admindeleted"] as? Bool ?? false
                        
                        if !isProfileDeleted && !isAdminDeleted {
                            let username = userData["username"] as? String ?? ""
                            let email = userData["email"] as? String ?? ""
                            let roles = userData["roles"] as? String ?? ""
                            let notification = userData["notification"] as? Bool ?? true
                            
                            
                            let user = SessionUsers(id: id,
                                                    username: username,
                                                    email: email,
                                                    notification: notification, roleType: roles)
                            
                            completion(user)
                        }else {
                            print("No User found")
                            completion(nil)
                        }
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
    func adminGetUserByID(withID id: String, completion: @escaping ([String: Any]?) -> Void) {
        let usersRef = reference.child(_collection)
        
        usersRef.child(id)
            .observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists() {
                    if let userData = snapshot.value as? [String: Any] {
                        completion(userData)
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
    func suspendProfile(userId: String, suspendedBy: String, reason: String, completion: @escaping (Bool) -> Void) {
        let updates: [String: Any] = [
            "suspended": true,
            "suspendedby": suspendedBy,
            "suspendedreason": reason,
            "suspendedon": Utils.getCurrentDatetime(),
            "isactive": false
        ]
        
        reference.child(_collection).child(userId).updateChildValues(updates) { error, _ in
            if let error = error {
                print("Failed to suspend profile: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func activateProfile(userId: String, completion: @escaping (Bool) -> Void) {
        let updates: [String: Any] = [
            "suspended": false,
            "suspendedby": NSNull(),
            "suspendedreason": NSNull(),
            "suspendedon": NSNull(),
            "isactive": true
        ]
        
        reference.child(_collection).child(userId).updateChildValues(updates) { error, _ in
            if let error = error {
                print("Failed to activate profile: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    func adminDeleteProfile(userId: String, completion: @escaping (Bool) -> Void) {
        let updates: [String: Any] = [
            "admindeleted": true,
            "admindeletedon": Utils.getCurrentDatetime(),
            "isactive": false
        ]
        
        reference.child(_collection).child(userId).updateChildValues(updates) { error, _ in
            if let error = error {
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func adminUnDeleteProfile(userId: String, completion: @escaping (Bool) -> Void) {
        let updates: [String: Any] = [
            "admindeleted": false,
            "admindeletedon": NSNull(),
            "isactive": true
        ]
        
        reference.child(_collection).child(userId).updateChildValues(updates) { error, _ in
            if error != nil {
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func deleteProfile(_ userID: String, completion: @escaping (Result<Void, Error>) -> Void) {
           reference.child(_collection).child(userID).removeValue { error, _ in
               if let error = error {
                   // On failure
                   completion(.failure(error))
               } else {
                   // On success
                   completion(.success(()))
               }
           }
       }
    
    func getModeratorList(completion: @escaping (Result<[Users], Error>) -> Void) {
        var moderatorsList = [Users]()
        
        reference.child(_collection).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                if let data = snapshot.value as? [String: Any] {
                    for (key, value) in data {
                        if let userData = value as? [String: Any],
                           let role = userData["roles"] as? String, role == "moderator" {
                            // Create Users instance with only necessary fields
                            let user = Users(
                                userId: key,
                                username: userData["username"] as? String ?? "",
                                email: userData["email"] as? String ?? "",
                                roles: role // Add only the fields you need
                            )
                            moderatorsList.append(user)
                        }
                    }
                    print("Moderators loaded: \(moderatorsList.count)") // Debug print
                    completion(.success(moderatorsList))
                } else {
                    completion(.failure(NSError(domain: "UserService", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Data format error."])))
                }
            } else {
                print("No moderators found")
                completion(.success(moderatorsList)) // Return empty list if no moderators found
            }
        } withCancel: { error in
            completion(.failure(error)) // Return error if there's an issue fetching data
        }
    }
    
    
    func setbackdeleteProfile(_ userID: String) {
     
        let reference = Database.database().reference()

        reference.child("users").child(userID).updateChildValues(["isDeleted": false]) { error, _ in
            if let error = error {
                print("Error restoring profile: \(error.localizedDescription)")
            } else {
                print("Profile restored successfully.")
            }
        }
    }
    
}
