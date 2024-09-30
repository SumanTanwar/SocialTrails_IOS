//
//  SignInView.swift
//  SocialTrailsApp
//
//  Created by Admin on 9/30/24.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct SignInView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var navigateToDashboard: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                Image("socialtrails_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(5)
                
                Text("Discover new experiences, share moments, and stay updated with the latest news from those who matter most.")
                                .foregroundColor(Color.purple) // Replace with your color
                                .font(.system(size: 14, design: .rounded))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 30)
                                .padding(.trailing, 30)
                                .padding(.bottom,5)
                
                VStack(spacing: 15) {
                    TextField("Email Address", text: $email)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    
                    HStack {
                        if isPasswordVisible {
                            TextField("Password", text: $password)
                                .padding()
                        } else {
                            SecureField("Password", text: $password)
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
                }
                .padding(.horizontal, 25)
                
               
                HStack {
                    Text("Forgot Password?")
                        .foregroundColor(.gray)
                    
                    NavigationLink(destination:SignUpView()) {
                        Text("Reset it here")
                            .foregroundColor(.blue)
                            .underline(true, color: .blue)
                    }
                }
                Button(action: {
                    loginUser()
                }) {
                    Text("Sign In")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple)
                        .cornerRadius(10)
                        .padding(.horizontal, 30)
                }
                .padding(.vertical, 20)
                
                HStack {
                    Text("Don't have a profile?")
                        .foregroundColor(.gray)
                    
                    NavigationLink(destination: SignUpView()) {
                        Text("Create new one")
                            .foregroundColor(.blue)
                            .underline(true, color: .blue)
                    }
                }
                .padding(.bottom, 200)
            }
            .background(Color.white)
            .navigationBarHidden(true)
            
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Invalid email address and password"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .fullScreenCover(isPresented: $navigateToDashboard, content: {
                            DashboardView()
                                .onDisappear() {
                                  
                                    navigateToDashboard = false
                                }
                        })
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func loginUser() {
        
        if email.isEmpty {
            showAlert(message: "Email is required.")
            return
        } else if !Utils.isValidEmail(email) {
            showAlert(message: "Invalid email address.")
            return
        }

       
        if password.isEmpty {
            showAlert(message: "Password is required.")
            return
        } else if password.count < 8 {
            showAlert(message: "Password should be more than 8 characters.")
            return
        } else if !Utils.isPasswordValid(password) {
            showAlert(message: "Password must contain at least one letter and one digit.")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                    if let error = error {
                        self.showAlert(message: error.localizedDescription)
                    } else if let authResult = authResult {
                        let user = authResult.user
                        
                       
                        if user.isEmailVerified {
                            print("User ID: \(user.uid)")
                            SessionManager.shared.loginUser(userid: user.uid) { success in
                                if success {
                                    self.navigateToDashboard = true
                                } else {
                                    self.showAlert(message: "Failed to log in. Please try again later.")
                                }
                            }
                            // Proceed to the dashboard
                        } else {
                            self.showAlert(message: "Please verify your email before signing in.")
                        }
                    } else {
                        self.showAlert(message: "Authentication failed. Please try again later.")
                    }
                }
    }

    
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
