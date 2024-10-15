import SwiftUI

struct AdminUserList: View {
    @State private var usersList: [Users] = []
    @State private var isLoading = true
    private var userService = UserService()
    @State private var showCreateModerator = false // State for presenting the create moderator view

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // User List
                if isLoading {
                    ProgressView("Loading users...")
                } else if usersList.isEmpty {
                    Text("No users found.")
                        .padding()
                } else {
                    List(usersList) { user in
                        NavigationLink(destination: AdminUserManageView(userId: user.userId)) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(user.username)
                                        .font(.headline)
                                    Text(user.email)
                                        .font(.subheadline)
                                }
                                Spacer()
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("User List")
                        .font(.headline)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AdminCreateModeratorView()) {
                        Text("Moderator")
                            .foregroundColor(.blue)
                    }
                }
            }
            .onAppear {
                loadUserList()
            }
        }
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
                DispatchQueue.main.async {
                    self.isLoading = false // Ensure loading state is updated
                }
            }
        }
    }
}
