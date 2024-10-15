import SwiftUI

struct AdminUserList: View {
    @State private var usersList: [Users] = []
    @State private var isLoading = true
    private var userService = UserService()
    
    var body: some View {
        List(usersList) { user in
            NavigationLink(destination: AdminUserManageView(userId: user.userId)) {
                Text(user.username) // Update with your cell configuration
            }
        }
        .onAppear {
            loadUserList()
        }
        .navigationTitle("User List")
    }

    private func loadUserList() {
        userService.getRegularUserList { result in
            switch result {
            case .success(let users):
                DispatchQueue.main.async {
                    self.usersList = users
                    self.isLoading = false
                }
            case .failure(let error):
                print("Error loading users: \(error.localizedDescription)")
            }
        }
    }
}
