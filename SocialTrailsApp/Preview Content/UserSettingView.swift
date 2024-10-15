import SwiftUI
import Firebase
import FirebaseAuth

struct UserSettingView: View {
    
    @ObservedObject var sessionManager = SessionManager.shared
    let userService = UserService()
    @State private var notification = true
    @State private var navigateToSignIn = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var notificationsEnabled = false
    @State private var showConfirmationDialog = false
    @State private var isLoggedOut = false
    
    private var dividerView: some View {
        Divider()
            .background(.gray)
            .font(.system(size: 3))
    }
    
  
        
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 20) {
                    if let url = sessionManager.getCurrentUser()?.profilepicture, let imageUrl = URL(string: url) {
                        AsyncImage(url: imageUrl) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle()) // Clip the image to a circle
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundColor(Color(.systemGray4))
                                .clipShape(Circle()) // Clip the placeholder to a circle as well
                        }
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(Color(.systemGray4))
                            .clipShape(Circle()) // Clip the default placeholder to a circle
                    }

                    
                    VStack(alignment: .leading) {
                        if let currentUser = sessionManager.getCurrentUser() {
                            Text(currentUser.username)
                                .font(.system(size: Utils.fontSize24))
                                .foregroundStyle(Utils.blackListColor)
                                .padding(.leading, 10)
                        } else {
                            Text("Unknown User")
                                .font(.system(size: Utils.fontSize24))
                                .foregroundStyle(Utils.blackListColor)
                                .padding(.leading, 10)
                        }
                    }
                }
                
                dividerView.padding(.horizontal, 10)
                
                Text("Manage your account information and preferences to personalize your experience.")
                    .font(.system(size: Utils.fontSize16))
                    .foregroundStyle(Utils.blackListColor)
                    .padding(.leading, 10)
            
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("My Settings")
                        .font(.system(size: Utils.fontSize20))
                        .foregroundStyle(Utils.blackListColor)
                        .fontWeight(.bold)
                    
                    dividerView
                    
                    HStack {
                        Text("Activate notifications")
                        Spacer()
                        Toggle(isOn: $notificationsEnabled) {
                            Text("")
                        }
                        .toggleStyle(SwitchToggleStyle(tint: Color(.systemGreen)))
                        .padding(.trailing)
                    }
                    .onAppear {
                        notificationsEnabled = sessionManager.getCurrentUser()?.notification ?? false
                    }
                    .onChange(of: notificationsEnabled) { newValue in
                        guard let userID = sessionManager.getCurrentUser()?.id else {
                            print("User ID is not available.")
                            return
                        }
                        userService.setNotification(userID, isEnabled: newValue) { result in
                            switch result {
                            case .success:
                                print("Notification setting updated successfully.")
                            case .failure(let error):
                                print("Failed to update notification setting: \(error.localizedDescription)")
                                notificationsEnabled.toggle()
                            }
                        }
                    }
                    
                    dividerView
                    
                    NavigationLink(destination: ChangePasswordView()) {
                        Text("Change Password")
                            .foregroundStyle(Utils.blackListColor)
                            .font(.system(size: Utils.fontSize16))
                    }
                    
                    dividerView
                    
                    
                    
                    
                    Button(action: {
                        showConfirmationDialog = true
                    }) {
                        Text("Delete Profile")
                            .foregroundColor(.black)
                    }
                    .alert("Are you sure you want to delete your profile?", isPresented: $showConfirmationDialog) {
                        Button("Cancel", role: .cancel) {}
                        Button("OK") {
                            userService.userprofiledelete()
                            sessionManager.logoutUser()
                            isLoggedOut = true
                        }
                    }
                    
                    
                    
                    dividerView
                    
                    Button(action: {
                        sessionManager.logoutUser()
                        navigateToSignIn = true
                    }) {
                        Text("Log Out")
                            .foregroundStyle(Utils.blackListColor)
                            .font(.system(size: Utils.fontSize16))
                    }
                    
                    dividerView
                    
                    
                    Spacer()
                }
                .padding(.leading, 10)
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
            }
        }
    }
}

struct UserSettingView_Previews: PreviewProvider {
    static var previews: some View {
        UserSettingView()
    }
}
