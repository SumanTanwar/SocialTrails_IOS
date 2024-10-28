
//
//  UserService.swift
//  SocialTrailsApp
//
//  Created by Admin on 9/29/24.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

enum UserServiceError: Error {
    case uploadError(String)
    case databaseError(String)
}

class UserService : ObservableObject{
    
    private var reference: DatabaseReference
    private var storageReference: StorageReference
    private let _collection = "users";
    
    init() {
        self.reference = Database.database().reference()
        self.storageReference = Storage.storage().reference()
    }
    
    func registerUser(_user:  Users, completion: @escaping (Bool) -> Void) {
       reference.child(_collection).child(_user.userId).setValue(_user.toDictionary()) { error, _ in
            if let error = error {
                print("Error writing user data: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
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
                            let bio = userData["bio"] as? String ?? ""
                            let roles = userData["roles"] as? String ?? ""
                            let notification = userData["notification"] as? Bool ?? true
                            let profilepicture = userData["profilepicture"] as? String ?? ""
                            
                            
                            let user = SessionUsers(id: id,
                                                    
                                                    username: username,
                                                    email: email, bio: bio,
                                                    notification: notification,
                                                    roleType: roles,
                                                    profilepicture: profilepicture)
                            
                            completion(user)
                        } else {
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
            if error != nil {
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
    
    func getRegularUserList(completion: @escaping (Result<[Users], Error>) -> Void) {
        reference.child(_collection).observeSingleEvent(of: .value) { snapshot in
            var usersList: [Users] = []

            guard snapshot.exists() else {
                completion(.success(usersList))
                return
            }

            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let user = try? childSnapshot.data(as: Users.self) {
                    if user.roles == UserRole.user.role {
                        usersList.append(user)
                    }
                }
            }

            completion(.success(usersList))
        } withCancel: { error in
            completion(.failure(error))
        }
    }

    
   func deleteProfile(_ userID: String, completion: @escaping (Result<Void, Error>) -> Void) {

       reference.child("profiledeleted").setValue(true) { error, _ in
                      if let error = error {
                          
                          print("Error updating profile deleted status: \(error.localizedDescription)")
                          completion(.failure(error))
                      } else {
                          print("Profile deleted status updated successfully.")
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
                           let role = userData["roles"] as? String, role == UserRole.moderator.role,
                           let isDeleted = userData["profiledeleted"] as? Bool, isDeleted == false{
                          
                            let user = Users(
                                userId: key,
                                username: userData["username"] as? String ?? "",
                                email: userData["email"] as? String ?? "", bio: "",
                                roles: role,
                                notification: userData["notification"] as? Bool ?? true
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
    
    
/*    func setbackdeleteProfile(_ userID: String) {
       Database.database().reference().child("users").child(userID).updateChildValues(["isDeleted": false]) { error, _ in
            if let error = error {
                print("Error restoring profile: \(error.localizedDescription)")
            } else {
                print("Profile restored successfully.")
            }
        }
    } */
    
    func userprofiledelete() {
          if let user = Auth.auth().currentUser {
              let userId = user.uid
              let ref = Database.database().reference().child(_collection).child(userId)
              
              ref.child("profiledeleted").setValue(true) { error, _ in
                  if let error = error {
                      print("Error updating profile deleted status: \(error.localizedDescription)")
                  } else {
                      print("Profile deleted status updated successfully.")
                                     
                                     // Now delete the user from Auth
                                     user.delete { error in
                                         if let error = error {
                                             print("Error deleting user: \(error.localizedDescription)")
                                         } else {
                                             print("User deleted successfully.")
                                             
                                             do {
                                                                try Auth.auth().signOut()
                                                            } catch {
                                                                print("Failed to log out after deletion: \(error.localizedDescription)")
                                                            }
                                         }
                                     }
                                 }
                             }
                         }  else {
              print("User ID not available.")
          }
      }
    
    func setNotification(_ userID: String, isEnabled: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        reference.child(_collection).child(userID).updateChildValues(["notification": isEnabled]) { error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func updateUser(_ user: Users, completion: @escaping (Bool) -> Void) {
       reference.child(_collection).child(user.userId).updateChildValues(user.toDictionary()) { error, _ in
            if let error = error {
                print("Error updating user: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    func uploadProfileImage(userId: String, imageData: Data, completion: @escaping (Result<String, UserServiceError>) -> Void) {
          let fileReference = storageReference.child("userprofile/\(userId)/\(UUID().uuidString).jpg")
          
          fileReference.putData(imageData, metadata: nil) { metadata, error in
              if let error = error {
                  completion(.failure(.uploadError(error.localizedDescription)))
                  return
              }
              
              fileReference.downloadURL { url, error in
                  if let error = error {
                      completion(.failure(.uploadError(error.localizedDescription)))
                  } else if let downloadUrl = url?.absoluteString {
                      self.addProfilePhoto(userId: userId, imageUrl: downloadUrl) { result in
                          switch result {
                          case .success:
                              completion(.success(downloadUrl))
                          case .failure(let error):
                              completion(.failure(error)) // Pass the UserServiceError directly
                          }
                      }
                  }
              }
          }
      }
      
      private func addProfilePhoto(userId: String, imageUrl: String, completion: @escaping (Result<Void, UserServiceError>) -> Void) {
          let updates: [String: Any] = [
              "profilepicture": imageUrl
          ]
          
          reference.child(_collection).child(userId).updateChildValues(updates) { error, _ in
              if let error = error {
                  completion(.failure(.databaseError(error.localizedDescription)))
              } else {
                  completion(.success(()))
              }
          }
      }

      func updateNameAndBio(userId: String, bio: String, username: String, completion: @escaping (Result<Void, UserServiceError>) -> Void) {
          let updates: [String: Any] = [
              "bio": bio,
              "username": username
          ]
          
          reference.child(_collection).child(userId).updateChildValues(updates) { error, _ in
              if let error = error {
                  completion(.failure(.databaseError(error.localizedDescription)))
              } else {
                  completion(.success(()))
              }
          }
      }
    func getUserByID(uid: String?, completion: @escaping (Result<Users, Error>) -> Void) {
        guard let uid = uid, !uid.isEmpty else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User ID is null or empty"])))
            return
        }
        
        reference.child(_collection).child(uid).observeSingleEvent(of: .value, with: { snapshot in
            if let userDict = snapshot.value as? [String: Any] {
                // Extracting data from userDict
                let username = userDict["username"] as? String ?? ""
                let email = userDict["email"] as? String ?? ""
                let bio = userDict["bio"] as? String
                let roles = userDict["roles"] as? String ?? ""
                let notification = userDict["notification"] as? Bool ?? true
                
                // Create a new Users instance directly
                let user = Users(
                    userId: uid,
                    username: username,
                    email: email,
                    bio: bio,
                    createdon: Utils.getCurrentDatetime(), // Ensure this returns a String
                    profilepicture: userDict["profilepicture"] as? String,
                    roles: roles,
                    notification: notification
                )
                
                // Check for deletion flags
                if !user.admindeleted && !user.profiledeleted {
                    completion(.success(user)) // Successfully found the user and passed deletion checks
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found or deleted"])))
                }
            } else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"])))
            }
        }) { error in
            completion(.failure(error))
        }
    }
    
    
    func getActiveUserList(completion: @escaping (Result<[Users], Error>) -> Void) {
        reference.child(_collection).observeSingleEvent(of: .value) { snapshot in
                var activeUsersList: [Users] = []

                guard snapshot.exists() else {
                    completion(.success(activeUsersList))
                    return
                }

                for child in snapshot.children {
                    if let childSnapshot = child as? DataSnapshot,
                       let user = try? childSnapshot.data(as: Users.self) {
                        // Check if the user is active, not marked as deleted, and not suspended
                        if user.roles == UserRole.user.role &&
                           !user.admindeleted &&
                           !user.profiledeleted &&
                           user.isactive {
                            activeUsersList.append(user)
                        }
                    }
                }

                completion(.success(activeUsersList))
            } withCancel: { error in
                completion(.failure(error))
            }
        }

  }
