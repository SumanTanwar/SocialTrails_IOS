import SwiftUI

struct SearchUserView: View {
    @State private var usersList: [Users] = []
    @State private var isLoading = true
    private var userService = UserService()
    let currentUserID = SessionManager.shared.getUserID()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
              
                Text("All Users")
                    .font(.headline)
                    .padding(.top)
                    .padding(.horizontal)
                
             
                Spacer(minLength: 5)

                if isLoading {
                    ProgressView("Loading users...")
                        .padding()
                } else if usersList.isEmpty {
                    Text("No users found.")
                        .padding()
                } else {
                    List(usersList) { user in
                        NavigationLink(destination: FollowUnfollowView(userId: user.userId)) {
                            HStack {
                             
                                if let profilePictureURL = user.profilepicture,
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
                                }
                                
                                Spacer()
                            }
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
        userService.getActiveUserList { result in
            switch result {
            case .success(let users):
                DispatchQueue.main.async {
                    self.usersList = users.filter { $0.userId != currentUserID }
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

struct SearchUserView_Previews: PreviewProvider {
    static var previews: some View {
        SearchUserView()
    }
}
