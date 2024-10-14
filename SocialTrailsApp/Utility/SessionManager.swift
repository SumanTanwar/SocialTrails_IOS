import Foundation
import Firebase
import FirebaseAuth

class SessionManager : ObservableObject {
    static let shared = SessionManager()
    
    private let userService = UserService()
    
    @Published private var currentUser: SessionUsers?
    
    var isLoggedIn: Bool {
        return currentUser != nil
    }
    
    func loginUser(userid: String, completion: @escaping (Bool) -> Void) {
        userService.fetchUserByUserID(withID : userid) { [weak self] (user) in
            if let user = user {
                self?.currentUser = user
                completion(true)
            } else {
                self?.currentUser = nil
                completion(false)
            }
        }
    }

    func logoutUser() {
        do {
            try Auth.auth().signOut()
            currentUser = nil
            
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    func updateNotificationSetting(notification: Bool) {
        if var currentUser = currentUser {
            currentUser.notification = notification
            self.currentUser = currentUser
        }
    }
    
    func getCurrentUser() -> SessionUsers? {
        return currentUser
    }
    
    func getNotificationStatus() -> Bool {
          return currentUser?.notification ?? false
      }

      func setNotificationStatus(_ isEnabled: Bool) {
       UserDefaults.standard.set(isEnabled, forKey: "notification")}
    
    func getUserID() -> String {
           return currentUser?.id ?? ""
       }

       func updateUserInfo(username: String, bio: String, profileImageUrl: String?) {
           if var currentUser = currentUser {
               currentUser.username = username
               currentUser.bio = bio
               currentUser.profileImageUrl = profileImageUrl
               self.currentUser = currentUser
               
               // Optionally, you might want to persist these changes to the database here
               // For example:
               let updatedUser = Users(
                   userId: currentUser.id,
                   username: currentUser.username,
                   email: currentUser.email,
                   bio: currentUser.bio,
                   profilepicture: profileImageUrl ?? currentUser.profileImageUrl,
                   roles: currentUser.roleType
               )
               userService.updateUser(updatedUser) { success in
                   if success {
                       print("User info updated successfully.")
                   } else {
                       print("Error updating user info.")
                   }
               }
           }
       }
    
}
