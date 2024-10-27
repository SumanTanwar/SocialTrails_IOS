//
//  UserPostsDetailView.swift
//  SocialTrailsApp
//
//  Created by Admin on 10/24/24.
//

import SwiftUI


struct UserPostsDetailView: View {
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
                    ScrollViewReader { scrollProxy in
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(userPosts) { post in
                                    PostDetailRowView(post: post,posts: $userPosts)
                                        .padding(.horizontal)
                                        .id(post.postId)
                                }
                            }
                            .padding(.vertical)
                        }
                        .onAppear {
                            if let selectedPostId = selectedPostId {
                                scrollProxy.scrollTo(selectedPostId, anchor: .top)
                            }
                        }
                    }
                }
            }
        .onAppear {
            fetchUserPosts()
        }
        .navigationTitle("User Posts")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(false)
                .padding(.top, 0	)
    }

    private func fetchUserPosts() {
        let userId = sessionManager.getCurrentUser()?.id ?? ""
        userPostService.getAllUserPostDetail(userId: userId) { posts, error in
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
    UserPostsDetailView()
}

