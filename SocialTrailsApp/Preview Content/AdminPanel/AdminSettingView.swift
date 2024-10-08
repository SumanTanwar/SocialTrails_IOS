import SwiftUI
import FirebaseAuth

struct AdminSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isLoggedOut = false
    private var auth = Auth.auth()

    var body: some View {
        NavigationView {
            VStack {
               
                VStack {
                    Image("socialtrails_logo")
                        .resizable()
                        .frame(width: 150, height: 150)
                    
                    Text("Admin")
                        .font(.system(size: 24))
                        .fontWeight(.regular)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
                .padding(.bottom, 30)
                
                Divider()
                    .frame(height: 2)
                    .background(Color.gray)

                VStack(alignment: .leading) {
                  
                    Text("Admin Settings")
                        .font(.system(size: 24))
                        .fontWeight(.bold)
                        .padding(.bottom, 5)

                    Divider()
                        .frame(height: 2)
                        .background(Color.gray)
                    
                    // Create Moderator Button
                    NavigationLink(destination: DashboardView()) {
                        Text("Create Moderator")
                            .font(.system(size: 18))
                            .foregroundColor(.black)
                            .padding(.vertical, 12)
                    }
                    
                    Divider()
                        .frame(height: 2)
                        .background(Color.gray)

                    // Change Password Button
                    NavigationLink(destination: AdminChangePasswordView()) {
                        Text("Change Password")
                            .font(.system(size: 18))
                            .foregroundColor(.black)
                            .padding(.vertical, 12)
                    }

                    Divider()
                        .frame(height: 2)
                        .background(Color.gray)

                    // Log Out Button
                    Button(action: {
                        logout()
                    }) {
                        Text("Log Out")
                            .font(.system(size: 18))
                            .foregroundColor(.black)
                            .padding(.vertical, 12)
                    }

                    Divider()
                        .frame(height: 2)
                        .background(Color.gray)
                }
                .padding()
                .padding(.top, 10)

                Spacer()
            }
            .navigationBarTitle("Admin", displayMode: .inline)
            .background(
                NavigationLink(destination: SignInView(), isActive: $isLoggedOut) {
                    EmptyView()
                }
            )
        }
    }

    private func logout() {
        do {
            try auth.signOut()
            isLoggedOut = true
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

struct AdminSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AdminSettingsView()
    }
}
