//
//  AdminPostCommentViw.swift
//  SocialTrailsApp
//
//  Created by Admin on 10/27/24.
//

import SwiftUI
struct AdminPostCommentView: View {
    var postId: String
   
    @State private var comments: [PostComment] = []
    var onCommentUpdated: ((Int) -> Void)?

    var body: some View {
        VStack {
           
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(comments, id: \.postcommentId) { comment in
                        HStack {
                            if let url = URL(string: comment.userprofilepicture ?? "") {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                         .scaledToFill()
                                         .frame(width: 40, height: 40)
                                         .clipShape(Circle())
                                } placeholder: {
                                    Image("user")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                }
                            }

                            VStack(alignment: .leading) {
                                Text(comment.username ?? "Unknown User")
                                    .font(.headline)
                                Text(comment.commenttext)
                                    .font(.subheadline)
                            }

                            Spacer()

                            
                                Button(action: {
                                    deleteComment(comment)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(PlainButtonStyle())
                            
                        }
                        .padding()
                    }
                }
            }
            .onAppear {
                fetchComments()
            }
        }
        .padding()
    }

    private func fetchComments() {
        let postCommentService = PostCommentService()
        postCommentService.retrieveComments(postId: postId) { result in
            switch result {
            case .success(let fetchedComments):
                self.comments = fetchedComments
                onCommentUpdated?(fetchedComments.count)
                print("Fetched comments: \(fetchedComments)")
            case .failure(let error):
                print("Failed to fetch comments: \(error.localizedDescription)")
            }
        }
    }

    private func deleteComment(_ comment: PostComment) {
        let postCommentService = PostCommentService()
        postCommentService.removePostComment(commentId: comment.postcommentId!) { result in
            switch result {
            case .success:
                fetchComments()
            case .failure(let error):
                print("Error deleting comment: \(error.localizedDescription)")
            }
        }
    }
}
