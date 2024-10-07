import SwiftUI

struct AdminUserManageView: View {
    @StateObject private var userService = UserService()
    @State public var userId: String
    @State private var username: String = "User"
    @State private var email: String = ""
    @State private var bio: String = ""
    @State private var postsCount: Int = 0
    @State private var followersCount: Int = 0
    @State private var followingsCount: Int = 0
    @State private var reason: String = ""
    @State private var showReason: Bool = false
    @State private var showDeleteText: Bool = false
    @State private var deleteText : String = ""
    @State private var isSuspended: Bool = false
    @State private var profiledeleted: Bool = false
    @State private var userprofiledeleted: Bool = false
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""
    @ObservedObject private var sessionManager = SessionManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack {
                    Image("user")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .cornerRadius(40)
                    Text(username)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 5)
                }
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("\(postsCount) Posts")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(followersCount) Followers")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(followingsCount) Followings")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.leading, 10)
            }
            .padding(.top, 10)

            Text(bio)
                .font(.system(size: 12))
                .foregroundColor(.black)

            Text(email)
                .font(.system(size: 12))
                .foregroundColor(.black)

            if userprofiledeleted {
                Text("user deleted own profile")
                    .font(.system(size: 12))
                    .padding(4)
                    .foregroundColor(.white)
                    .background(Color.red)
                    .cornerRadius(5)
            }

            else
            {
                if showReason {
                    Text("Suspended profile: \(reason)")
                        .font(.system(size: 12))
                        .padding(4)
                        .foregroundColor(.white)
                        .background(Color.orange)
                        .cornerRadius(5)
                }
                
                if showDeleteText {
                    Text(deleteText)
                        .font(.system(size: 12))
                        .padding(4)
                        .foregroundColor(.white)
                        .background(Color.red)
                        .cornerRadius(5)
                }
                
                
                HStack {
                    Button(action: {
                        if isSuspended {
                            adminUnSuspendProfile()
                        } else {
                            showSuspendDialog()
                        }
                    }) {
                        Text(isSuspended ? "UnSuspend Profile" : "Suspend Profile")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.black)
                            .cornerRadius(5)
                    }
                    .padding(.horizontal, 8)
                    
                    Button(action: {
                        if profiledeleted {
                            adminUnDeleteProfile()
                        } else {
                            adminDeleteProfile()
                        }
                    }) {
                        Text(profiledeleted ? "Activate Profile" : "Delete Profile")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.black)
                            .cornerRadius(5)
                    }
                    .padding(.horizontal, 8)
                }
                
                .padding(.top, 10)
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .onAppear {
            fetchUserDetails()
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func fetchUserDetails() {
        userService.adminGetUserByID(withID: userId) { userData in
            guard let userData = userData else {
                print("No user found")
                return
            }
            self.username = userData["username"] as? String ?? "Unknown User"
            self.email = userData["email"] as? String ?? ""
            self.bio = userData["bio"] as? String ?? ""
            self.isSuspended = userData["suspended"] as? Bool ?? false
            self.showDeleteText = userData["admindeleted"] as? Bool ?? false
            self.profiledeleted = userData["admindeleted"] as? Bool ?? false
            self.userprofiledeleted = userData["profiledeleted"] as? Bool ?? false
            self.showReason = userData["suspended"] as? Bool ?? false
            self.reason = userData["suspendedreason"] as? String ?? ""
            self.deleteText = "Deleted profile by admin on  \(userData["admindeletedon"] as? String ?? "")"
        }
    }

    private func showAlert(message: String) {
        alertMessage = message
        showingAlert = true
    }

    private func showSuspendDialog() {
        let alert = UIAlertController(title: "Suspend Profile", message: "Please provide a reason for suspending \(self.username) profile", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Reason for suspension"
        }
        alert.addAction(UIAlertAction(title: "Confirm", style: .default) { _ in
            if let reason = alert.textFields?.first?.text, !reason.isEmpty {
                self.reason = reason
                adminSuspendProfile()
            } else {
                showAlert(message: "Suspend reason is required.")
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
    }

    private func adminSuspendProfile() {
        let adminuserId = sessionManager.getCurrentUser()?.id ?? ""
        userService.suspendProfile(userId: userId, suspendedBy: adminuserId, reason: self.reason) { success in
            if success {
                self.isSuspended = true
                self.showReason = true
            } else {
                self.isSuspended = false
                self.reason = ""
                self.showReason = false
                showAlert(message: "Suspend profile failed! Please try again later.")
            }
        }
    }

    private func adminUnSuspendProfile() {
        userService.activateProfile(userId: userId) { success in
            if success {
                self.isSuspended = false
                self.reason = ""
                self.showReason = false
            } else {
                showAlert(message: "Activate profile failed! Please try again later.")
            }
        }
    }

    private func adminDeleteProfile() {
        userService.adminDeleteProfile(userId: userId) { success in
            if success {
                self.showDeleteText = true
                self.profiledeleted = true
                self.deleteText = "Deleted profile by admin on \(Utils.getCurrentDatetime())"
              
            } else {
                showAlert(message: "delete profile failed! Please try again later.")
            }
        }
    }

    private func adminUnDeleteProfile() {
        userService.adminUnDeleteProfile(userId: userId) { success in
            if success {
                self.showDeleteText = false
                self.profiledeleted = false
                self.deleteText = ""
              
            } else {
                showAlert(message: "activate profile failed! Please try again later.")
            }
        }
    }
}

struct AdminUserManageView_Previews: PreviewProvider {
    static var previews: some View {
        AdminUserManageView(userId: "m2IMctFyVmS4jVZzPdl0EgIXSBL2")
    }
}
