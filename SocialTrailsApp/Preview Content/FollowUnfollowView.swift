import SwiftUI

struct FollowUnfollowView: View {
  
    @State public var userId: String
    @State private var username: String = "User"
    @State private var bio: String = "Bio"
    @State private var postsCount: Int = 0
    @State private var followersCount: Int = 0
    @State private var followingsCount: Int = 0

    @State private var showReportDialog: Bool = false
    @State private var reportReason: String = ""
    @State private var userPosts: [UserPost] = []
    @State private var profilePicture: String?
    
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""
    @State var isPendingRequest: Bool = false
    @State private var showConfirmationButtons: Bool = false

    @State private var isFollowedBack: Bool = false
    
    @State private var isFollowing: Bool = false
    @State private var showFollowSection: Bool = true
    @State private var showUnfollowSection: Bool = false
   @State private var showConfirmSection: Bool = false
   @State private var showFollowBackSection: Bool = false
    @State private var showCancelRequestSection: Bool = false

    
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
                        
                        NavigationLink(destination: FollowersListView()) {
                            VStack {
                                Text("\(followersCount) ")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                                Text("Followers")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                            }.padding(.leading, 25)
                        }
                        
                        NavigationLink(destination: FollowingsListView()) {
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
            }
            .padding(.top, 10)

            Text(bio)
                .font(.system(size: 12))
                .foregroundColor(.black)
                .padding(.leading, 10)

            HStack {
                           if isPendingRequest {
                               Button(action: cancelFollowRequest) {
                                   Text("Cancel Request")
                                       .frame(maxWidth: .infinity)
                                       .padding(.vertical, 8)
                                       .background(Color.blue)
                                       .foregroundColor(.white)
                                       .cornerRadius(5)
                               }
                           } else {
                               Button(action: isFollowing ? cancelFollowRequest : sendFollowRequest) {
                                   Text(isFollowing ? "Unfollow" : "Follow")
                                       .frame(maxWidth: .infinity)
                                       .padding(.vertical, 8)
                                       .background(isFollowing ? Color.blue : Color.blue)
                                       .foregroundColor(.white)
                                       .cornerRadius(5)
                               }
                           }
                Button(action: {
                    showReportDialog.toggle()
                }) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.red)
                }
                .padding(.trailing, 8)
            }
            
            if showConfirmationButtons {
                            HStack {
                                Button(action: {
                                    confirmFollowRequest() // Confirm follow request
                                }) {
                                    Text("Confirm")
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(5)
                                }
                                .padding(.trailing, 8)

                                Button(action: {
                                    rejectFollowRequest() // Reject follow request
                                }) {
                                    Text("Reject")
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(5)
                                }
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
            checkUserFollowStatus(userId)
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
            
            followService.getFollowCounts(for: userId, callback: self)
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
    private func checkFollowingStatus() {
           let currentUserId = sessionManager.getUserID()
           followService.getFollowAndFollowerIdsByUserId(userId: currentUserId) { ids, error in
               if let error = error {
                   print("Error fetching follow status: \(error.localizedDescription)")
                   return
               }
               if let ids = ids {
                   self.isFollowing = ids.contains(userId)
               }
           }
       }

    
    private func checkUserFollowStatus(_ userIdToCheck: String) {
           followService.checkUserFollowStatus(currentUserId: sessionManager.getUserID(), userIdToCheck: userIdToCheck) { result in
               switch result {
               case .success(let following):
                   isFollowing = following
                   isPendingRequest = false // Resetting pending request status
                   checkPendingFollowRequestsForCancel(userIdToCheck)
               case .failure:
                   isFollowing = false
                   isPendingRequest = false
               }
           }
       }
    
    private func sendFollowRequest() {
            let currentUserId = sessionManager.getUserID()
            followService.sendFollowRequest(currentUserId: currentUserId, userIdToFollow: userId) { result in
                switch result {
                case .success:
                    self.isPendingRequest = true
                    alertMessage = "Follow request sent!"
                    showingAlert = true
                case .failure(let error):
                    alertMessage = "Error sending follow request: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }
    
    private func cancelFollowRequest() {
            let currentUserId = sessionManager.getUserID()
            followService.cancelFollowRequest(currentUserId: currentUserId, userIdToUnfollow: userId) { result in
                switch result {
                case .success:
                    self.isPendingRequest = false
                    self.isFollowing = false
                    alertMessage = "Follow request canceled!"
                    showingAlert = true
                case .failure(let error):
                    alertMessage = "Error canceling follow request: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }
    
    private func checkPendingFollowRequestsForCancel(_ userIdToCheck: String) {
           let currentUserId = sessionManager.getUserID()
           followService.checkPendingRequestsForCancel(currentUserId: currentUserId, userIdToCheck: userIdToCheck) { result in
               switch result {
               case .success(let pending):
                   self.isPendingRequest = pending
               case .failure:
                   self.isPendingRequest = false
               }
           }
       }
    
    

    private func confirmFollowRequest() {
          let currentUserId = sessionManager.getUserID()
        followService.confirmFollowRequest(currentUserId: currentUserId, userIdToFollow: userId) { result in
              switch result {
              case .success:
                  alertMessage = "Follow request confirmed!"
                  isFollowing = true
                  isPendingRequest = false
                  showingAlert = true
                  // Additional logic if needed
              case .failure(let error):
                  alertMessage = "Error: \(error.localizedDescription)"
                  showingAlert = true
              }
          }
      }

      private func rejectFollowRequest() {
          let currentUserId = sessionManager.getUserID()
          followService.rejectFollowRequest(currentUserId: currentUserId, userIdToFollow: userId) { result in
              switch result {
              case .success:
                  alertMessage = "Follow request rejected!"
                  isPendingRequest = false
                  isFollowing = false
                  showingAlert = true
                  // Update UI to reflect changes
              case .failure(let error):
                  alertMessage = "Error: \(error.localizedDescription)"
                  showingAlert = true
              }
          }
      }
    func checkFollowBack(userIdToCheck: String) {
        let currentUserId = sessionManager.getUserID()

        followService.checkIfFollowed(currentUserId: currentUserId, userIdToCheck: userIdToCheck) { result in
            // Directly use self since FollowUnfollowView is a struct
            switch result {
            case .success(let isFollowing):
                self.isFollowing = isFollowing
                self.isFollowedBack = isFollowing // User is following

            case .failure:
                self.isFollowing = false
            }

            // Check if followed back if not following
            if !self.isFollowing {
                self.followService.checkIfFollowed(currentUserId: userIdToCheck, userIdToCheck: currentUserId) { result in
                    switch result {
                    case .success(let isFollowedBack):
                        self.isFollowedBack = isFollowedBack
                    case .failure:
                        self.isFollowedBack = false
                    }
                }
            }
        }
    }

    private func followBack() {
        let currentUserId = sessionManager.getUserID()
        
        followService.followBack(currentUserId: currentUserId, userIdToFollow: userId) { result in
            switch result {
            case .success:
                showAlert(message: "You are now following this user!")
                updateUIForFollowBack()
            case .failure(let error):
                showAlert(message: "Error: \(error.localizedDescription)")
            }
        }
    }


    private func updateUIForFollowBack() {
        showFollowSection = false
        showUnfollowSection = true
        showConfirmSection = false
        showFollowBackSection = false
        showCancelRequestSection = false
    }

    private func unfollowUser() {
           let currentUserId = sessionManager.getUserID()
           followService.unfollowUser(currentUserId: currentUserId, userIdToUnfollow: userId) { result in
               switch result {
               case .success:
                   DispatchQueue.main.async {
                       self.isFollowing = false
                       showAlert(message: "You have successfully unfollowed the user.")
                   }
               case .failure(let error):
                   DispatchQueue.main.async {
                       showAlert(message: "Error: \(error.localizedDescription)")
                   }
               }
           }
       }

    

    private func showAlert(message: String) {
        alertMessage = message
        showingAlert = true
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

extension FollowUnfollowView: DataOperationCallback {
    func onSuccess(followersCount: Int, followingsCount: Int) {
        self.followersCount = followersCount
        self.followingsCount = followingsCount
    }

    func onFailure(_ error: String) {
        print(error)
    }
}

struct FollowUnfollowView_Previews: PreviewProvider {
    static var previews: some View {
        FollowUnfollowView(userId: "sample_user_id")
    }
}
