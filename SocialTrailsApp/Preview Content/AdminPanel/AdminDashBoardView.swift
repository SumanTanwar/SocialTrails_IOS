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
                
            }
        }
    }

}

struct AdminDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        AdminDashboardView()
    }
}
