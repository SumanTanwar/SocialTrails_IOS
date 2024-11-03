//
//  NotificationService.swift
//  SocialTrailsApp
//
//  Created by Admin on 11/2/24.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

class NotificationService {
    private var reference: DatabaseReference
    private let collectionName = "notifications"
   
    private var userService: UserService

    init() {
        let database = Database.database().reference()
        self.reference = database
      
        self.userService = UserService()
    }

    func sendNotificationToUser(notification: Notification) {
        let notificationRef = reference.child(collectionName)
        let notificationId = notificationRef.childByAutoId().key
        
        notification.notificationId = notificationId
        
        if let notificationId = notificationId {
            notificationRef.child(notificationId).setValue(notification.toDictionary()) { error, _ in
                if let error = error {
                    print("Failed to send notification: \(error.localizedDescription)")
                } else {
                    print("Notification sent successfully.")
                }
            }
        } else {
            print("Failed to generate notification ID.")
        }
    }

    func fetchNotifications(for userId: String, callback: @escaping (Result<[Notification], Error>) -> Void) {
        let notificationRef = reference.child(collectionName)

        notificationRef.queryOrdered(byChild: "notifyto").queryEqual(toValue: userId).observe(.value) { (snapshot : DataSnapshot) in
            var notifications: [Notification] = []
            let userFetchGroup = DispatchGroup()
            
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let notification = Notification(snapshot: snapshot) {
                    userFetchGroup.enter()
                    self.retrieveUserDetails(for: notification.notifyBy) { result in
                        switch result {
                        case .success(let userDetails):
                            notification.username = userDetails.username
                            notification.userProfilePicture = userDetails.profilepicture
                            notifications.append(notification)
                        case .failure(let error):
                            print("Failed to fetch user details: \(error.localizedDescription)")
                            notifications.append(notification) // Add even if user details fail
                        }
                        userFetchGroup.leave()
                    }
                }
            }

            userFetchGroup.notify(queue: .main) {
                if notifications.isEmpty {
                    callback(.success(notifications))
                } else {
                    // Sort notifications by createdOn timestamp
                    notifications.sort { $0.createdon > $1.createdon }
                    callback(.success(notifications))
                }
            }
        } withCancel: { error in
            print("Error fetching notifications: \(error.localizedDescription)")
            callback(.failure(error))
        }
    }

    private func retrieveUserDetails(for userId: String, callback: @escaping (Result<Users, Error>) -> Void) {
        userService.getUserByID(uid : userId) { result in
            switch result {
            case .success(let user):
                callback(.success(user))
            case .failure:
                callback(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"])))
            }
        }
    }
}
