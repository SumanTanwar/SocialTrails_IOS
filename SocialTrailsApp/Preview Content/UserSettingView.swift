//
//  UserSettingView.swift
//  SocialTrailsApp
//
//  Created by Suman Tanwar on 2024-10-08.
//

import SwiftUI
import Firebase
import FirebaseAuth


struct UserSettingView: View {
    
    @ObservedObject var sessionManager = SessionManager.shared
    @State private var notificationsEnabled = true
    @State private var navigateToSignIn = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    private var dividerView: some View {
        Divider()
            .background(.gray)
            .font(.system(size: 3))
    }
    private var topViewMsg: some View {
        Text("Manage your account information and preferences to personalize your experience.")
            .font(.system(size: Utils.fontSize16))
            .foregroundStyle(Utils.blackListColor)
            .padding(.leading, 10)
    }
    
    var body: some View {
        
        
        NavigationStack {
            VStack(alignment: .leading, spacing: 10)  {
                HStack(spacing: 20) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 80,height: 80)
                        .clipShape(Circle())
                        .padding()
                    
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
                
                topViewMsg
                
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    
                    
                    Text("My Settings")
                        .font(.system(size: Utils.fontSize20))
                        .foregroundStyle(Utils.blackListColor)
                        .fontWeight(.bold)
                    
                    
                    dividerView
                    
                    HStack {
                        
                        Toggle(isOn: $notificationsEnabled){
                            Text("Activate Notifications")
                                .foregroundStyle(Utils.blackListColor)
                                .font(.system(size: Utils.fontSize16))
                        }
                    }
                    
                    dividerView
                    
                    NavigationLink(destination: ChangePasswordView()){
                        Text("Change Password")
                            .foregroundStyle(Utils.blackListColor)
                            .font(.system(size: Utils.fontSize16))
                    }
                    
                    dividerView
                    
                    Button(action: {
                        navigateToSignIn = true
                    }){
                        Text("Delete Profile")
                            .foregroundStyle(Utils.blackListColor)
                            .font(.system(size: Utils.fontSize16))
                    }
                    .alert(alertMessage, isPresented: $showAlert) {
                        Button("OK", role: .cancel) {}
                    }
                    .confirmationDialog("Delete Account", isPresented: $navigateToSignIn) {
                        Text("Are you sure you want to delete your account?")
                        Button("Yes", role: .destructive) {
                            deleteAccount()
                        }
                        Button("No", role: .cancel) {}
                    }
                    
                    dividerView
                    
                    Button(action: {
                        sessionManager.logoutUser()
                        navigateToSignIn = true
                    }){
                        Text("Log Out")
                            .foregroundStyle(Utils.blackListColor)
                            .font(.system(size: Utils.fontSize16))
                    }
                    
                    dividerView
                    
                }.padding()
                
                Spacer()
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
        }
    }
    
    private func deleteAccount() {
        guard let user = Auth.auth().currentUser else {
            alertMessage = "Delete profile failed, please try again later."
            showAlert = true
            return
        }
        
        let userService = UserService()
        guard let userID = sessionManager.getCurrentUser()?.id else {
            alertMessage = "Delete profile failed, please try again later."
            showAlert = true
            return
        }

        userService.deleteProfile(userID) { result in
            switch result {
            case .success:
                user.delete { error in
                    if let error = error {
                        userService.setbackdeleteProfile(userID)
                        alertMessage = "Delete profile failed: \(error.localizedDescription)"
                        showAlert = true
                    } else {
                        SessionManager.shared.logoutUser()
                        do {
                            try Auth.auth().signOut()
                        } catch {
                            alertMessage = "Failed to log out: \(error.localizedDescription)"
                            showAlert = true
                        }
                    }
                }
            case .failure(let error):
                userService.setbackdeleteProfile(userID)
                alertMessage = "Delete profile failed: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }

}
  

  struct UserSettingView_Previews: PreviewProvider {
      static var previews: some View {
          UserSettingView()
      }
  }
