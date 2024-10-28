import SwiftUI

struct CommentDialog: View {
    var postId: String
    @State private var commentText: String = ""
    @State private var comments: [PostComment] = []
    var onCommentAdded: () -> Void

    var body: some View {
        VStack {
            Text("Add a Comment")
                .font(.headline)

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

                            // Show delete button if conditions are met
                            if shouldShowDeleteButton(for: comment) {
                                Button(action: {
                                    deleteComment(comment)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .onAppear {
                fetchComments()
            }
            HStack {
                TextField("Write your comment...", text: $commentText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .frame(maxHeight: 50)

                Button("Send") {
                    addComment()
                }
                .foregroundColor(.white)
                .frame(width: 80, height: 40)
                .background(Color.purple)
                .cornerRadius(10)
                .padding(.leading, 8)
                .disabled(commentText.isEmpty)
            }
            .padding()
        }
        .padding()
    }

    private func fetchComments() {
        let postCommentService = PostCommentService()
        postCommentService.retrieveComments(postId: postId) { result in
            switch result {
            case .success(let fetchedComments):
                self.comments = fetchedComments
            case .failure(let error):
                print("Failed to fetch comments: \(error.localizedDescription)")
            }
        }
    }

    private func addComment() {
        let userId = SessionManager.shared.getCurrentUser()?.id ?? ""
        let newComment = PostComment(postId: postId, userId: userId, commenttext: commentText)

        let postCommentService = PostCommentService()
        postCommentService.addPostComment(data: newComment) { result in
            switch result {
            case .success:
                onCommentAdded()
                commentText = ""
                fetchComments()
            case .failure(let error):
                print("Error adding comment: \(error.localizedDescription)")
            }
        }
    }

    private func shouldShowDeleteButton(for comment: PostComment) -> Bool {
        let currentUserId = SessionManager.shared.getCurrentUser()?.id ?? ""
        let roleType = SessionManager.shared.getCurrentUser()?.roleType
        
        return (roleType == UserRole.user.rawValue && (comment.userId == currentUserId || currentUserId == postId)) ||
        (roleType == UserRole.admin.rawValue || roleType == UserRole.moderator.rawValue)
    }

    private func deleteComment(_ comment: PostComment) {
        let postCommentService = PostCommentService()
        postCommentService.removePostComment(commentId: comment.postcommentId!) { result in
            switch result {
            case .success:
                onCommentAdded()
                comments.removeAll { $0.postcommentId == comment.postcommentId }
            case .failure(let error):
                print("Error deleting comment: \(error.localizedDescription)")
            }
        }
    }
}
