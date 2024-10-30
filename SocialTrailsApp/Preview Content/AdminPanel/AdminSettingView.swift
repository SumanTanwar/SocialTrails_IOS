import SwiftUI
import FirebaseAuth

struct AdminSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isLoggedOut = false
    @State private var navigateToSignIn = false
    private var auth = Auth.auth()
    @State private var isAdmin: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                
                VStack {
                    Image("socialtrails_logo")
                        .resizable()
                        .frame(width: 150, height: 150)
                    
                  
                    Text(isAdmin ? "Admin" : "Moderator")
                        .font(.system(size: 18))
                        .fontWeight(.regular)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 10)

                VStack(alignment: .leading) {
                    
                    Text(isAdmin ? "Admin Settings" : "Moderator Settings")
                        .font(.system(size: 16))
                        .fontWeight(.bold)

                    Divider()
                        .frame(height: 2)
                        .background(Color.gray)
                        .padding(.horizontal, -16)

                    
                    if isAdmin {
                        NavigationLink(destination: AdminCreateModeratorView()) {
                            Text("Create Moderator")
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                                .padding(.vertical, 8)
                        }

                        Divider()
                            .frame(height: 2)
                            .background(Color.gray)
                            .padding(.horizontal, -16)
                    }

                   
                    NavigationLink(destination: AdminChangePasswordView()) {
                        Text("Change Password")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .padding(.vertical, 8)
                    }

                    Divider()
                        .frame(height: 2)
                        .background(Color.gray)
                        .padding(.horizontal, -16)

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
                        SignInView()
                    }

                    Divider()
                        .frame(height: 2)
                        .background(Color.gray)
                        .padding(.horizontal, -16)
                }
                .padding()
                .padding(.top, 10)

                Spacer()
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .onAppear {
                checkIfAdmin() // Check if user is admin on view appear
            }
        }
    }

    private func checkIfAdmin() {
        if let user = auth.currentUser {
            
            isAdmin = user.email?.hasSuffix("socialtrails2024.com") ?? false
        }
    }
}

struct AdminSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AdminSettingsView()
    }
}
