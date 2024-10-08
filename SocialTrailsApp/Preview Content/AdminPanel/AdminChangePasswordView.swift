import SwiftUI
import Firebase
import FirebaseAuth

struct AdminChangePasswordView: View {
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var isCurrentPasswordVisible: Bool = false
    @State private var isNewPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var navigateToSignIn: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                Image("socialtrails_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(5)

                Text("Change Password")
                    .font(.largeTitle)
                    .padding(.top, 20)
                    .padding(.bottom, 20)

                Text("Enter your current password and new password to change.")
                    .foregroundColor(Color.purple)
                    .font(.system(size: 15))
                    .padding(.bottom, 5)

                VStack(spacing: 15) {
                    passwordField(placeholder: "Current Password", password: $currentPassword, isVisible: $isCurrentPasswordVisible)
                    passwordField(placeholder: "New Password", password: $newPassword, isVisible: $isNewPasswordVisible)
                    passwordField(placeholder: "Confirm New Password", password: $confirmPassword, isVisible: $isConfirmPasswordVisible)
                }
                .padding()

                Button(action: {
                    changePassword()
                }) {
                    Text("Change Password")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple)
                        .cornerRadius(10)
                        .padding(.horizontal, 30)
                }
                .padding(.vertical, 20)

                NavigationLink(destination: DashboardView(), label: {
                    Text("Back")
                        .foregroundColor(.blue)
                })
                .padding(.bottom, 200)
            }
            .background(Color.white)
            .navigationBarHidden(true)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .fullScreenCover(isPresented: $navigateToSignIn, content: {
                SignInView()
            })
        }
        .navigationBarBackButtonHidden(true)
    }

    // Function to create the password fields with visibility toggle
    private func passwordField(placeholder: String, password: Binding<String>, isVisible: Binding<Bool>) -> some View {
        HStack {
            if isVisible.wrappedValue {
                TextField(placeholder, text: password)
                    .padding()
            } else {
                SecureField(placeholder, text: password)
                    .padding()
            }
            Button(action: {
                isVisible.wrappedValue.toggle()
            }) {
                Image(systemName: isVisible.wrappedValue ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.gray)
                    .padding(10)
            }
        }
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }

    // Function to change password
    private func changePassword() {
        // Validate passwords
        guard !currentPassword.isEmpty, !newPassword.isEmpty, !confirmPassword.isEmpty else {
            showAlert(message: "All fields are required.")
            return
        }

        guard newPassword == confirmPassword else {
            showAlert(message: "New password and confirmation do not match.")
            return
        }

        guard newPassword.count >= 8 else {
            showAlert(message: "New password should be at least 8 characters long.")
            return
        }

        
        let user = Auth.auth().currentUser
        let credential = EmailAuthProvider.credential(withEmail: user?.email ?? "", password: currentPassword)

        user?.reauthenticate(with: credential) { result, error in
            if let error = error {
                self.showAlert(message: error.localizedDescription)
                return
            }

            user?.updatePassword(to: newPassword) { error in
                if let error = error {
                    self.showAlert(message: error.localizedDescription)
                } else {
                    showAlert(message: "Password changed successfully. Please sign in again.")
                
                    do {
                        try Auth.auth().signOut()
                        navigateToSignIn = true
                    } catch {
                        showAlert(message: "Failed to sign out.")
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

struct AdminChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        AdminChangePasswordView()
    }
}
