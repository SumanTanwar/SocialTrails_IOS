import SwiftUI

struct AdminDashboardView: View {
   
    @State private var adminName: String = "Admin"
    @State private var adminEmail: String = "socialtrails2024@gmail.com"
    @State private var isLoggedOut = false

    var body: some View {
        NavigationStack {
            VStack {
                VStack(alignment: .leading) {
                    Text("Welcome, \(adminName)!")
                        .font(.title)
                        .padding(.bottom, 5)
                    
                    Text("Email: \(adminEmail)")
                        .font(.subheadline)
                        .padding(.bottom, 20)
                }
                .padding()

                
                Button(action: {
                    logout()
                }) {
                    Text("Logout")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding(.bottom, 20)
                
                NavigationLink(destination: AdminUserList()) {
                    Text("User List")
                        .foregroundStyle(Utils.blackListColor)
                        .font(.system(size: Utils.fontSize16))
                }
                
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $isLoggedOut) {
                SignInView() // Replace with your actual sign-in view
            }
          
        }
    }

    private func logout() {
        SessionManager.shared.logoutUser()
        isLoggedOut = true
    }
}

struct AdminDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        AdminDashboardView()
    }
}
