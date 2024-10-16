import SwiftUI

struct AdminUserList: View {
    @State private var usersList: [Users] = []
    @State private var isLoading = true
    private var userService = UserService()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if isLoading {
                    ProgressView("Loading users...")
                } else if usersList.isEmpty {
                    Text("No users found.")
                        .padding()
                } else {
                    List(usersList) { user in
                        NavigationLink(destination: AdminUserManageView(userId: user.userId)) {
                            HStack {
                                // Profile Image or Default Image
                                if let profilePictureURL = user.profilepicture, !profilePictureURL.isEmpty,
                                   let url = URL(string: profilePictureURL) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                    } placeholder: {
                                        ProgressView()
                                    }
                                } else {
                                    // Default person icon if no profile picture
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.gray)
                                        .clipShape(Circle())
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(user.username)
                                        .font(.headline)
                                    Text(user.email)
                                        .font(.subheadline)
                                }
                                
                                Spacer()
                                
                                // Status Indicator
                                if user.suspended {
                                    Text("Suspended")
                                        .foregroundColor(.orange)
                                        .font(.caption)
                                } else if user.profiledeleted {
                                    Text("Deleted")
                                        .foregroundColor(.red)
                                        .font(.caption)
                                } else {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 12, height: 12)
                                }
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
                        HStack {
                                       Image(systemName: "person.badge.plus")
                                           .resizable()
                                           .frame(width: 20, height: 20)
                                           .foregroundColor(.black)
                                       
                                       Text("Moderator")
                                           .foregroundColor(.black)
                                   }
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
                    self.isLoading = false
                }
            }
        }
    }
}

struct AdminUserList_Previews: PreviewProvider {
    static var previews: some View {
        AdminUserList()
    }
}
