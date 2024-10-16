import SwiftUI
import FirebaseAuth

struct AdminCreateModeratorView: View {
    @StateObject private var sessionManager = SessionManager.shared
    
    @State private var name = ""
    @State private var email = ""
    @State private var generatedPassword = ""
    @State private var errorMessage = ""
    @State private var navigateToModeratorList = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image("socialtrails_logo")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .padding()
                
                Text("Create Moderator")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                
                TextField("Moderator username", text: $name)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                    .autocapitalization(.none)
                
                TextField("Moderator email", text: $email)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)

                Button(action: createModerator) {
                    Text("Create Moderator")
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top, 10)
                
                 /*   if !generatedPassword.isEmpty {
                    VStack(spacing: 10) {
                        Text("Generated Password: \(generatedPassword)")
                        
                        Button(action: {
                            UIPasteboard.general.string = generatedPassword
                            showError("Password copied to clipboard")
                        }) {
                            Text("Copy Password")
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }  */
                
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
                Spacer()
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .padding(16)
            .background(
                NavigationLink(destination: AdminModeratorListView(), isActive: $navigateToModeratorList) {
                    EmptyView()
                }
            )
        }
    }
    private func createModerator() {
        guard validateInputs() else { return }

        generatedPassword = generateRandomPassword(length: 8)
        
        Auth.auth().createUser(withEmail: email, password: generatedPassword) { authResult, error in
            if let error = error {
                showError(error.localizedDescription)
                return
            }
            
            if let user = authResult?.user {
                do {
                    // Send email verification
                    try user.sendEmailVerification()
                    
                    // Create a new moderator
                    let newModerator = Users(
                        userId: user.uid,
                        username: name,
                        email: email,
                        roles: UserRole.moderator.role,
                        notification: true // Default value
                    )
                    
                    // Register the new moderator using the session manager
                    sessionManager.registerModerator(newModerator) { success in
                        if success {
                            print("Moderator added successfully!")
                            try? Auth.auth().signOut()  // Sign out after creation
                            clearInputs()
                            navigateToModeratorList = true  // Trigger navigation
                        } else {
                            showError("Failed to add moderator to database.")
                        }
                    }
                } catch {
                    showError("Failed to send verification email: \(error.localizedDescription)")
                }
            }
        }
    }


    private func validateInputs() -> Bool {
        if name.isEmpty {
            showError("Name is required")
            return false
        }
        if email.isEmpty {
            showError("Email is required")
            return false
        }
        return true
    }
    
    private func generateRandomPassword(length: Int) -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#%^&*()"
        return String((0..<length).compactMap { _ in characters.randomElement() })
    }
    
    private func clearInputs() {
        name = ""
        email = ""
        generatedPassword = ""
    }
    
    private func showError(_ message: String) {
        errorMessage = message
    }
}

struct AdminCreateModeratorView_Previews: PreviewProvider {
    static var previews: some View {
        AdminCreateModeratorView()
    }
}
