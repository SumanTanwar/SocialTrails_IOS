//
//  ForgotPasswordView.swift
//  SocialTrailsApp
//
//  Created by Barsha Roka on 2024-09-30.
//
import SwiftUI
import Firebase
import FirebaseAuth

struct ForgotPasswordView: View {
    @State private var email: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var navigateToSignIn: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                Image("socialtrails_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(.bottom,1)
                Text("Reset Password")
                    .font(.largeTitle)
                    .padding(.top,1)
                
                Text("Enter your email address to receive a link to reset your password")
                                .foregroundColor(Color.black)                  .font(.system(size: 14, design: .rounded))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.init(top: 5, leading: 10, bottom: 5, trailing: 10))
                TextField("Email", text: $email)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal, 10)

                Button(action: resetPassword) {
                    Text("Reset ")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple)
                        .cornerRadius(10)
                        .padding(.horizontal, 10)
                }
                .padding(.vertical, 10)

                NavigationLink(destination: SignInView(), isActive: $navigateToSignIn) {
                    Text("Back to Login")
                        .foregroundColor(.blue)
                        .padding(.top,10)
                }

                Spacer()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Notification"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .padding()
            .background(Color.white)
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
        }
    }

    private func resetPassword() {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            showAlert(message: "Email is required")
            return
        }

        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                showAlert(message: "Failed to send reset email: \(error.localizedDescription)")
            } else {
                showAlert(message: "Check your email to reset your password")
                navigateToSignIn = true
            }
        }
    }

    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
