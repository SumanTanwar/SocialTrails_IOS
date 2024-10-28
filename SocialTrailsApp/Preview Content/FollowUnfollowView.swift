import SwiftUI

struct FollowUnfollowView: View {
  
    @State public var userId: String
    @State private var username: String = "User"
    @State private var bio: String = "Bio"
    @State private var postsCount: Int = 0
    @State private var followersCount: Int = 0
    @State private var followingsCount: Int = 0
    @State private var isFollowing: Bool = false
    @State private var showReportDialog: Bool = false
    @State private var reportReason: String = ""
    @State private var userPosts: [UserPost] = []
    @State private var profilePicture: String?
    
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""
    
    @ObservedObject private var sessionManager = SessionManager.shared
    @StateObject private var userService = UserService()
    @StateObject private var userPostService = UserPostService()
    @StateObject private var followService = FollowService()

    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack {
                    if let url = profilePicture, let imageUrl = URL(string: url) {
                        AsyncImage(url: imageUrl) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundColor(Color(.systemGray4))
                                .clipShape(Circle())
                        }
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(Color(.systemGray4))
                            .clipShape(Circle())
                    }

                   
                        Text(username)
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .padding(.leading, 10)
                    
                }
                
                VStack(alignment: .leading) {
                    HStack {
                        VStack {
                            Text("\(postsCount) ")
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                            Text("Posts")
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                        }.padding(.leading, 20)
                        
                        VStack {
                            Text("\(followersCount) ")
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                            Text("Followers")
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                        }.padding(.leading, 25)
                        
                        VStack {
                            Text("\(followingsCount) ")
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                            Text("Followings")
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                        }.padding(.leading, 25)
                    }
                }
            }
            .padding(.top, 10)

            Text(bio)
                .font(.system(size: 12))
                .foregroundColor(.black)
                .padding(.leading, 10)

            HStack {
                Button(action: {
                    isFollowing ? unfollowUser() : followUser()
                }) {
                    Text(isFollowing ? "Unfollow" : "Follow")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
                .padding(.trailing, 8)

                Button(action: {
                    showReportDialog.toggle()
                }) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.red)
                }
                .padding(.trailing, 8)
            }
            
            if !userPosts.isEmpty {
                let columns = [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ]
                
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach($userPosts, id: \.postId) { $post in
                        
                        if let imageUrls = post.uploadedImageUris, !imageUrls.isEmpty {
                           
                            if let firstImageUrl = imageUrls.first {
                                NavigationLink(destination: AdminPostDetailView(postDetailId: post.postId)) {
                                    AsyncImage(url: URL(string: firstImageUrl)) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 130, height: 130)
                                            .clipped()
                                            .cornerRadius(0)
                                            .overlay(RoundedRectangle(cornerRadius: 0)
                                                        .stroke(Color.gray, lineWidth: 1))
                                    } placeholder: {
                                        ProgressView()
                                            .frame(width: 130, height: 130)
                                            .background(Color.gray.opacity(0.2))
                                            .overlay(RoundedRectangle(cornerRadius: 0)
                                                        .stroke(Color.gray, lineWidth: 1))
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 17)
            }

        }
        .padding(.init(top: -1, leading: 5, bottom: 0, trailing: 5))

        Spacer()
        .sheet(isPresented: $showReportDialog) {
            reportDialog
        }
        .onAppear {
            fetchUserDetails()
            fetchUserPosts()
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func fetchUserDetails() {
        userService.adminGetUserByID(withID: userId) { userData in
            guard let userData = userData else {
                print("No user found")
                return
            }
            self.username = userData["username"] as? String ?? "Unknown User"
            self.bio = userData["bio"] as? String ?? ""
            self.profilePicture = userData["profilepicture"] as? String ?? ""
            self.followersCount = userData["followersCount"] as? Int ?? 0
            self.followingsCount = userData["followingsCount"] as? Int ?? 0
        }
    }

    private func fetchUserPosts() {
        userPostService.getAllUserPosts(userId: userId) { result in
            switch result {
            case .success(let posts):
                self.userPosts = posts
                self.postsCount = posts.count
            case .failure(let error):
                print("Error fetching user posts: \(error.localizedDescription)")
                showAlert(message: "Error fetching user posts: \(error.localizedDescription)")
            }
        }
    }

    private func showAlert(message: String) {
        alertMessage = message
        showingAlert = true
    }


    private func followUser() {
       
        isFollowing = true
    }

    private func unfollowUser() {
       
        isFollowing = false
    }

    private var reportDialog: some View {
        VStack {
            Text("Report User")
                .font(.headline)

            TextField("Reason for reporting", text: $reportReason)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Submit") {
                submitReport()
                showReportDialog.toggle()
            }
            .padding()

            Button("Cancel") {
                showReportDialog.toggle()
            }
            .padding()
        }
        .padding()
        .frame(width: 300)
    }

    private func submitReport() {
    
        print("Report submitted with reason: \(reportReason)")
    }
}


struct FollowUnfollowView_Previews: PreviewProvider {
    static var previews: some View {
        FollowUnfollowView(userId: "sample_user_id")
    }
}
