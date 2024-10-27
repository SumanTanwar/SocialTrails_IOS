import SwiftUI

struct DashboardView: View {
    @StateObject private var userPostService = UserPostService()
    @State private var userPosts: [UserPost] = []
    @State private var isLoading = true
    @ObservedObject private var sessionManager = SessionManager.shared
    var selectedPostId: String?

    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack {
                    HStack {
                        if let url = sessionManager.getCurrentUser()?.profilepicture, let imageUrl = URL(string: url) {
                            AsyncImage(url: imageUrl) { image in
                                image
                                    .resizable()
                                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            }
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .foregroundColor(Color(.systemGray4))
                        }

                        Text(sessionManager.getCurrentUser()?.username ?? "Unknown")
                            .font(.system(size: 16, weight: .bold))
                            .layoutPriority(1)

                        Spacer()

                        Image(systemName: "heart")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    .padding(.vertical, 3)
                    .padding(.horizontal, 10)

                    Divider()

                    if userPosts.isEmpty {
                        Text("You haven't followed anyone yet. Start following users to view their posts in your feed.")
                            .font(.system(size: 18))
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .padding(.top, 300)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(userPosts) { post in
                                    PostDetailRowView(post: post,posts: $userPosts)
                                        .padding(.horizontal)
                                        .id(post.postId)
                                }
                            }
                            .padding(.top, 0)
                        }
                    }
                }
                .padding(0)
            }
        }
        .onAppear {
            fetchUserPosts()
        }
        .navigationTitle("User Posts")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true) 
    }

    private func fetchUserPosts() {
        let userId = sessionManager.getCurrentUser()?.id ?? ""
        userPostService.retrievePostsForFollowedUsers(currentUserId: userId) { posts, error in
            if let error = error {
                print("Error fetching user posts: \(error.localizedDescription)")
            } else {
                userPosts = posts ?? []
            }
            isLoading = false
        }
    }
}

#Preview {
    DashboardView()
}
