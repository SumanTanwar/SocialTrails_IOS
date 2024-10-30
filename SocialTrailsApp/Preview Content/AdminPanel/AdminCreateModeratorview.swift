import SwiftUI
import FirebaseAuth

struct AdminCreateModeratorView: View {
    @StateObject private var sessionManager = SessionManager.shared
    
    @State private var name = ""
    @State private var email = ""
    @State private var errorMessage = ""
    @State private var navigateToAdminDashboard = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    private let fixedPassword = "tempass123"

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
                NavigationLink(destination: AdminDashboardView(), isActive: $navigateToAdminDashboard) {
                    EmptyView()
                }
            )
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Success"), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                    navigateToAdminDashboard = true
                })
            }
        }
    }
    
    private func createModerator() {
        guard validateInputs() else { return }
        
        // Use the fixed password instead of generating one
        Auth.auth().createUser(withEmail: email, password: fixedPassword) { authResult, error in
            if let error = error {
                showError(error.localizedDescription)
                return
            }
            
            if let user = authResult?.user {
                // Send password reset email
                Auth.auth().sendPasswordReset(withEmail: email) { error in
                    if let error = error {
                        showError("Failed to send password reset email: \(error.localizedDescription)")
                        return
                    }
                    
                    let newModerator = Users(
                        userId: user.uid,
                        username: name,
                        email: email,
                        roles: UserRole.moderator.role
                    )
                    
                    sessionManager.registerModerator(newModerator) { success in
                        if success {
                            print("Moderator added successfully!")
                            
                            alertMessage = "Moderator created successfully. A password reset email has been sent."
                            showAlert = true;                             try? Auth.auth().signOut()
                            clearInputs()
                        } else {
                            showError("Failed to add moderator to database.")
                        }
                    }
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
    
    private func clearInputs() {
        name = ""
        email = ""
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

