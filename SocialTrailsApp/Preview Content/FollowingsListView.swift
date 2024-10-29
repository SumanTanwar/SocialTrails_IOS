import SwiftUI

struct FollowingsListView: View {
    @State private var followingsList: [Users] = []
    @State private var isLoading = true
    private var followService = FollowService()
    let currentUserID = SessionManager.shared.getUserID()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Followings")
                    .font(.headline)
                    .padding(.horizontal)

                Spacer(minLength: 5)

                if isLoading {
                    ProgressView("Loading followings...")
                        .padding()
                } else if followingsList.isEmpty {
                    Text("No followings found.")
                        .padding()
                } else {
                    List(followingsList) { user in
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
                loadFollowings()
            }
        }
    }
    
    private func loadFollowings() {
        followService.getFollowingDetails(userId: currentUserID) { result in
            switch result {
            case .success(let followings):
                DispatchQueue.main.async {
                    self.followingsList = followings
                    self.isLoading = false
                }
            case .failure(let error):
                print("Error loading followings: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
}

struct FollowingsListView_Previews: PreviewProvider {
    static var previews: some View {
        FollowingsListView()
    }
}
