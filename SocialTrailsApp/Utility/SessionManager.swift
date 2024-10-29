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
    
    func getUserID() -> String {
           return currentUser?.id ?? ""
       }

       func updateUserInfo(username: String, bio: String, profilepicture: String?) {
           if var currentUser = currentUser {
               currentUser.username = username
               currentUser.bio = bio
               currentUser.profilepicture = profilepicture
               self.currentUser = currentUser

             
           }
       }
    func loginAdmin(userid: String,email: String, completion: @escaping (Bool) -> Void) {
        let adminUser = SessionUsers(
                   id: userid,
                   username: "Admin",
                   email: email,
                   bio: "",
                   notification: false, // Set the default notification preference
                   roleType: UserRole.admin.role,
                   profilepicture: ""
               )
               
               // Set the current user to the admin user
               self.currentUser = adminUser
               completion(true)
    }
    
    func registerModerator(_ user: Users, completion: @escaping (Bool) -> Void) {
        userService.registerUser(_user: user) { success in
               completion(success)
           }
       }
    func getRoleType() -> String {
           return UserDefaults.standard.string(forKey: "roleType") ?? ""
       }

}
