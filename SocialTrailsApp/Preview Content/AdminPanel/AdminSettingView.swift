import SwiftUI
import FirebaseAuth

struct AdminSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isLoggedOut = false
    @State private var navigateToSignIn = false
    private var auth = Auth.auth()

    var body: some View {
        NavigationStack {
            VStack {
                // Logo and Title
                VStack {
                    Image("socialtrails_logo")
                        .resizable()
                        .frame(width: 150, height: 150)
                    
                    Text("Admin")
                        .font(.system(size: 18))
                        .fontWeight(.regular)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 10)
             
                VStack(alignment: .leading) {
                    Text("Admin Settings")
                        .font(.system(size: 16))
                        .fontWeight(.bold)

                    Divider()
                        .frame(height: 2)
                        .background(Color.gray)
                        .padding(.horizontal, -16) // Adjust horizontal padding

                    // Create Moderator Button
                    NavigationLink(destination: AdminCreateModeratorView()) {
                        Text("Create Moderator")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .padding(.vertical, 8)
                    }
                    
                    Divider()
                        .frame(height: 2)
                        .background(Color.gray)
                        .padding(.horizontal, -16) // Adjust horizontal padding

                    // Change Password Button
                    NavigationLink(destination: AdminChangePasswordView()) {
                        Text("Change Password")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .padding(.vertical, 8)
                    }

                    Divider()
                        .frame(height: 2)
                        .background(Color.gray)
                        .padding(.horizontal, -16) // Adjust horizontal padding

                    Button(action: {
                           SessionManager.shared.logoutUser()
                           navigateToSignIn = true
                       }) {
                           Text("Log Out")
                               .font(.system(size: 16))
                               .foregroundColor(.black)
                               .padding(.vertical, 8)
                       }
                       .fullScreenCover(isPresented: $navigateToSignIn) {
                           SignInView() // Present the Sign In view
                       }

                    Divider()
                        .frame(height: 2)
                        .background(Color.gray)
                        .padding(.horizontal, -16) // Adjust horizontal padding
                }
                .padding()
                .padding(.top, 10)

                Spacer()
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
        }
    }
}

struct AdminSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AdminSettingsView()
    }
}
