import SwiftUI

struct FollowersListView: View {
    var userId: String
    @State private var followersList: [Users] = []
    @State private var isLoading = true
  
   
     var body: some View {
        NavigationView {
            VStack {
                Text("Followers")
                    .font(.headline)
                    .padding(.horizontal)

                Spacer(minLength: 5)

                if isLoading {
                    ProgressView("Loading followers...")
                        .padding()
                } else if followersList.isEmpty {
                    Text("No followers found.")
                        .padding()
                }else {
                    List(followersList) { user in
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
                loadFollowers()
            }
        }
    }
    
    private func loadFollowers() {
         let followService = FollowService()
        followService.getFollowersDetails(userId: userId) { result in
            switch result {
            case .success(let followers):
                DispatchQueue.main.async {
                    self.followersList = followers
                    self.isLoading = false
                }
            case .failure(let error):
                print("Error loading followers: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }

}
