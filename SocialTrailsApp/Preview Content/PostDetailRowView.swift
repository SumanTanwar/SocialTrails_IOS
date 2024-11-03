//
//  PostDetailRowView.swift
//  SocialTrailsApp
//
//  Created by Admin on 10/24/24.
//
import SwiftUI
import GoogleMaps
import GooglePlaces


struct PostDetailRowView: View {
    @ObservedObject var post: UserPost 
    @ObservedObject private var sessionManager = SessionManager.shared
    @StateObject private var userPostService = UserPostService()
    @StateObject private var reportService = ReportService()

     
    @State private var showAlert = false
    @State private var alertMessage: String?
    @State private var showConfirmationDialog = false
    @Binding var posts: [UserPost]
    @State private var showLikesDialog = false
    @State private var showCommentDialog = false
    @State private var showMapView = false
    @State private var showReportPopup = false
    
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
                        .onTapGesture {
                                                showMapView = true
                                            }
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
                                  toggleLike()
                              }) {
                                  Image(systemName: post.isliked ?? false ? "heart.fill" : "heart")
                                      .resizable()
                                      .frame(width: 18, height: 18)
                                      .foregroundColor(post.isliked ?? false ? .red : .primary)
                              }

                              Text("\(post.likecount ?? 0)")
                                  .font(.subheadline)
                                  .onTapGesture {
                                      if let likeCount = post.likecount, likeCount > 0 {
                                                                  showLikesDialog.toggle()
                                                              }
                                  }

                Button(action: {
                                  showCommentDialog = true
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
                        showReportPopup.toggle()
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
        .sheet(isPresented: $showLikesDialog) {
            PostLikesList(postId: post.postId)
        }
        .sheet(isPresented: $showCommentDialog) {
                   CommentDialog(postId: post.postId, onCommentAdded: {
                       fetchComments() 
                   })
               }
        .sheet(isPresented: $showMapView) {
            if let latitude = post.latitude, let longitude = post.longitude {
             MapOnlyView(selectedLocation: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            }
        }
        .onAppear(){
            checkLikeStatus()
        }
        .sheet(isPresented: $showReportPopup) {
            ReportPopup(isPresented: $showReportPopup, reportedId: post.postId, reportType: ReportType.post.rawValue)
        }

    
    }
   
    private func fetchComments() {
        let postCommentService = PostCommentService()
        postCommentService.retrieveComments(postId: post.postId) { result in
            switch result {
            case .success(let fetchedComments):
                
                post.commentcount = fetchedComments.count
            case .failure(let error):
                print("Failed to fetch comments: \(error.localizedDescription)")
            }
        }
    }
    private func checkLikeStatus() {
          guard let userId = sessionManager.getCurrentUser()?.id else { return }
          
          let postLikeService = PostLikeService()
        postLikeService.getPostLikeByUserAndPostId(postId: post.postId,userId: userId) { result in
              switch result {
              case .success(_):
                  post.isliked = true
              case .failure(_):
                  post.isliked = false
                 
              }
          }
      }
    private func toggleLike() {
          let postLikeService = PostLikeService()
          let userId = sessionManager.getCurrentUser()?.id ?? ""
          postLikeService.likeAndUnlikePost(postId: post.postId, userId: userId) { result in
              switch result {
              case .success(let likeResult):
               
                  post.isliked = likeResult.isliked
                  post.likecount = likeResult.count
              case .failure(let error):
                  alertMessage = "Failed to like/unlike post: \(error.localizedDescription)"
                  showAlert = true
              }
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
