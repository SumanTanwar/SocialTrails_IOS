//
//  PostLikesList.swift
//  SocialTrailsApp
//
//  Created by Admin on 10/27/24.
//

import SwiftUI

struct PostLikesList: View {
    let postId: String
    
    @State private var likes: [PostLike] = []
   
    @ObservedObject private var sessionManager = SessionManager.shared
    var onLikesUpdated: ((Int) -> Void)?
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach($likes, id: \.postlikeId) { $like in
                        HStack {
                            if let url = like.profilepicture, let imageUrl = URL(string: url) {
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

                           
                           
                        Text(like.username ?? "Unknown")
                        .font(.headline)
                                
                               
                            Spacer()

                            
                            if sessionManager.getCurrentUser()?.roleType == UserRole.admin.rawValue ||
                               sessionManager.getCurrentUser()?.roleType == UserRole.moderator.rawValue {
                                Button(action: {
                                    removeLike(like.postlikeId)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .padding()
            }
           // .navigationTitle("Likes")
            .onAppear {
                loadLikes()
            }
        }
    }

    private func loadLikes() {
        let postLikeService = PostLikeService()
        postLikeService.getLikesForPost(postId: postId) { result in
            switch result {
            case .success(let likesList):
                likes = likesList
                onLikesUpdated?(likesList.count)
            case .failure:
                likes = []
            }
        }
    }
    
    private func removeLike(_ postlikeId: String) {
        let postLikeService = PostLikeService()
        postLikeService.removeLike(postlikeId: postlikeId,postId:postId) { result in
            switch result {
            case .success:
                loadLikes()
            case .failure(let error):
                print("Failed to remove like: \(error.localizedDescription)")
            }
        }
    }
}
