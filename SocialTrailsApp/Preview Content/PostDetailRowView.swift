//
//  PostDetailRowView.swift
//  SocialTrailsApp
//
//  Created by Admin on 10/24/24.
//
import SwiftUI

import SwiftUI

struct PostDetailRowView: View {
    let post: UserPost
    @ObservedObject private var sessionManager = SessionManager.shared
    @StateObject private var userPostService = UserPostService()
    @State private var showAlert = false
    @State private var alertMessage: String?
    @State private var showConfirmationDialog = false
    @Binding var posts: [UserPost]
    @State private var isEditing = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
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

                Spacer()

                if post.userId == sessionManager.getCurrentUser()?.id {
                    Menu {
                        NavigationLink(destination: UserPostEditView(postId: post.postId)) {
                                                  Text("Edit")
                                              }
                        Button("Delete") {
                            showConfirmationDialog = true
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .resizable()
                            .frame(width: 18, height: 4)
                            .foregroundColor(.primary)
                            .aspectRatio(contentMode: .fit)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.top, 10)
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
                .font(.body)

            HStack {
                Button(action: {
                    // Like action here
                }) {
                    Image(systemName: "heart")
                        .resizable()
                        .frame(width: 18, height: 18)
                }

                Text("\(post.likecount ?? 0)")
                    .font(.subheadline)

                Button(action: {
                    // Comment action here
                }) {
                    Image(systemName: "message")
                        .resizable()
                        .frame(width: 18, height: 18)
                }

                Text("\(post.commentcount ?? 0)")
                    .font(.subheadline)
                
                Spacer()

                if post.userId != sessionManager.getCurrentUser()?.id {
                    Button(action: {
                        // Report action here
                    }) {
                        Image(systemName: "exclamationmark.triangle")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding(.vertical, 1)

            Text(Utils.getRelativeTime(from: post.createdon))
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .padding(5)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Notification"), message: Text(alertMessage ?? "An error occurred."), dismissButton: .default(Text("OK")))
        }
        .confirmationDialog("Are you sure you want to delete this post?", isPresented: $showConfirmationDialog) {
            Button("Delete", role: .destructive) {
                deletePost()
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $isEditing) {
                    UserPostEditView(postId: post.postId)
                }
    }

    private func deletePost() {
        userPostService.deleteUserPost(postId: post.postId) { result in
            switch result {
            case .success:
                if let index = posts.firstIndex(where: { $0.postId == post.postId }) {
                                   posts.remove(at: index)
                               }
                alertMessage = "Post deleted successfully."
                showAlert = true
            case .failure(let error):
                alertMessage = "Failed to delete post: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }
}
