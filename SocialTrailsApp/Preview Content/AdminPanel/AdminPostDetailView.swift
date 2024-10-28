import SwiftUI

struct AdminPostDetailView: View {
    var postDetailId: String
    @State private var userPost: UserPost?
    @State private var comments: [PostComment] = []
    @State private var likes: [PostLike] = []
    @State private var showingDeleteAlert = false
    @State private var navigateToUserManage = false
    @State private var userId: String?

    var body: some View {
        VStack {
            if let post = userPost {
                ScrollView {
                    VStack(alignment: .leading, spacing: 5) {
                        HStack() {
                            if let url = post.userprofilepicture, let imageUrl = URL(string: url) {
                                AsyncImage(url: imageUrl) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                                } placeholder: {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(Color(.systemGray4))
                                        .clipShape(Circle())
                                }
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(Color(.systemGray4))
                                    .clipShape(Circle())
                            }

                            VStack(alignment: .leading) {
                                Text(post.username ?? "Unknown")
                                    .font(.headline)
                                Text(post.location ?? "")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.bottom, 12)

                        TabView {
                            ForEach(post.uploadedImageUris ?? [], id: \.self) { imageUrl in
                                if let url = URL(string: imageUrl) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: UIScreen.main.bounds.width, height: 180)
                                            .cornerRadius(10)
                                    } placeholder: {
                                        Image("noimage")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: UIScreen.main.bounds.width, height: 180)
                                            .cornerRadius(10)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        .tabViewStyle(PageTabViewStyle())
                        .padding(.horizontal)
                        .frame(height: 180)

                        Text(post.captiontext)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack {
                            HStack {
                                Image(systemName: post.likecount ?? 0 > 0 ? "heart.fill" : "heart")
                                    .resizable()
                                    .frame(width: 18, height: 18)
                                    .foregroundColor(post.isliked ?? false ? .red : .gray)

                                Text("\(post.likecount ?? 0)")
                                    .font(.subheadline)
                            }

                           
                            HStack {
                                Image(systemName: "message")
                                    .resizable()
                                    .frame(width: 18, height: 18)

                                Text("\(post.commentcount ?? 0)")
                                    .font(.subheadline)
                            }
                        }

                        Text(Utils.getRelativeTime(from: post.createdon))
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                      

                        if let likeCount = post.likecount, likeCount > 0 {
                            Divider()
                            Text("Likes")
                                .font(.headline)
                                .bold()
                                
                            Divider()
                            PostLikesList(postId: post.postId, onLikesUpdated: { updatedCount in
                                post.likecount = updatedCount
                            })
                        }
                       
                        if let commentCount = post.commentcount, commentCount > 0 {
                            Divider()
                            Text("Comments")
                                .font(.headline)
                                .bold()
                               
                            Divider()
                            AdminPostCommentView(postId: post.postId, onCommentUpdated: { updatedCount in
                                print("")
                                post.commentcount = updatedCount
                            })
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .navigationTitle("Post Details")
        .onAppear {
            fetchUserPostDetail()
           
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Confirm Delete"),
                message: Text("Are you sure you want to delete this post?"),
                primaryButton: .destructive(Text("Delete")) {
                    deletePost()
                },
                secondaryButton: .cancel()
            )
        }
        .toolbar {
            Button(action: { showingDeleteAlert.toggle() }) {
                Text("Delete Post")
            }
        }
        .background(
            NavigationLink(destination: AdminUserManageView(userId: userId ?? ""), isActive: $navigateToUserManage) {
                EmptyView()
            }
        )
    }

    private func fetchUserPostDetail() {
        UserPostService().getUserPostDetailById(postId: postDetailId) { result in
            switch result {
            case .success(let post):
                self.userPost = post
            case .failure(let error):
                print("Failed to fetch post details: \(error.localizedDescription)")
            }
        }
    }

  

    private func deletePost() {
        guard let userId = userPost?.userId else { return }
        UserPostService().deleteUserPost(postId: postDetailId) { result in
            switch result {
            case .success:
                print("Post deleted successfully")
                self.userId = userId
                self.navigateToUserManage = true
            case .failure(let error):
                print("Failed to delete post: \(error.localizedDescription)")
            }
        }
    }
}
