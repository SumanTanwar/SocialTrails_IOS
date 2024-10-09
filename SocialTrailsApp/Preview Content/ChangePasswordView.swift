//
//  ChangePasswordView.swift
//  SocialTrailsApp
//
//  Created by Suman Tanwar on 2024-10-09.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct ChangePasswordView: View {
    
    @State private var password: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isNewPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var navigateToSignIn: Bool = false
    
    var body: some View {
        NavigationStack{
            VStack() {
                Image("socialtrails_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180,height: 180)
                
                
                Text("Change Password")
                    .font(.system(size: Utils.fontSize24))
                    .foregroundStyle(Utils.blackListColor)
                    .padding(10)
                
                VStack(spacing: 15) {
                    
                    HStack {
                        if isPasswordVisible {
                            TextField("Current Password", text: $password)
                                .padding()
                        } else {
                            SecureField("Current Password", text: $password)
                                .padding()
                        }
                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.gray)
                                .padding(10)
                        }
                    }
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    
                    HStack {
                        if isNewPasswordVisible {
                            TextField("New Password", text: $newPassword)
                                .padding()
                        }else {
                            SecureField("New Password", text: $newPassword)
                                .padding()
                        }
                        Button(action: {
                            isNewPasswordVisible.toggle()
                        }) {
                            Image(systemName: isNewPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.gray)
                                .padding(10)
                        }
                    }
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    
                    HStack {
                        if isConfirmPasswordVisible {
                            TextField("Confirm Password", text: $confirmPassword)
                                .padding()
                        }else {
                            SecureField("Confirm Password", text: $confirmPassword)
                                .padding()
                        }
                        Button(action: {
                            isConfirmPasswordVisible.toggle()
                        }) {
                            Image(systemName: isConfirmPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.gray)
                                .padding(10)
                        }
                    }
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    
                    
                }   .padding(.horizontal, 25)
                
               
                Button(action:changePassword) {
                    Text("Change Password")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple)
                        .cornerRadius(10)
                        .padding(.horizontal, 30)
                }
                .padding(.vertical, 20)
                NavigationLink(destination: SignInView(), isActive: $navigateToSignIn) {
                    EmptyView()
                }
            }.alert(alertMessage, isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
                
            }
            Spacer()
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
        }
    }
    private func changePassword() {
        showAlert = false
        alertMessage = ""
        
        guard let user = Auth.auth().currentUser else { return }

        if password.isEmpty {
            showAlert(message: "Current Password is required.")
            return
        } else if password.count < 8 {
            showAlert(message: "Password should be more than 8 characters.")
            return
        } else if !Utils.isPasswordValid(password) {
            showAlert(message: "Password must contain at least one letter and one digit.")
            return
        }
        
        if newPassword.isEmpty {
            showAlert(message: "New Password is required.")
            return
        } else if newPassword.count < 8 {
            showAlert(message: "Password should be more than 8 characters.")
            return
        } else if !Utils.isPasswordValid(newPassword) {
            showAlert(message: "Password must contain at least one letter and one digit.")
            return
        }
        
        if confirmPassword.isEmpty {
            showAlert(message: "Please confirm your password.")
            return
        } else if newPassword != confirmPassword {
            showAlert(message: "Passwords do not match.")
            return
        }
        
        let credential = EmailAuthProvider.credential(withEmail: user.email!, password: password)
        
        user.reauthenticate(with: credential) { (result, error) in
            if let error = error {
                showAlert(message: "Authentication failed: \(error.localizedDescription)")
                return
            }

            user.updatePassword(to: newPassword) { error in
                if let error = error {
                    showAlert(message: "Failed to change password: \(error.localizedDescription)")
                } else {
                    showAlert(message: "Password successfully changed! Please sign in with your new password.")
             
                    do {
                        try Auth.auth().signOut()
                        SessionManager.shared.logoutUser()
                        
                    } catch {
                        showAlert(message: "Failed to log out: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
}

#Preview {
    ChangePasswordView()
}
