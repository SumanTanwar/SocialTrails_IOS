import SwiftUI

struct FollowersListView: View {
    var followers: [String] // Assume this is an array of follower usernames or user IDs

    var body: some View {
        List(followers, id: \.self) { follower in
            Text(follower) // Display the follower name or other relevant info
        }
        .navigationTitle("Followers")
    }
}
