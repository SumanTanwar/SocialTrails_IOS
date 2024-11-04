import SwiftUI

struct AdminWarningListView: View {
    @StateObject private var viewModel = IssueWarningViewModel()

    var body: some View {
        VStack(alignment: .leading) {
            Text("Issued Warnings")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 8)

            Divider()

            List(viewModel.warnings) { warning in
                WarningRow(warning: warning) // Create a separate view for each row
            }
            .onAppear {
                viewModel.fetchIssueWarnings()
            }
            .listStyle(PlainListStyle())
        }
        .padding()
    }
}

struct WarningRow: View {
    let warning: IssueWarning // Accept single warning

    var body: some View {
        HStack(alignment: .top) {
            // User Profile Image
            if let imageUrl = warning.userprofilepicture, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .padding(.trailing, 8)
                } placeholder: {
                    Image(systemName: "person.circle.fill") // Default image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .padding(.trailing, 8)
                }
            } else {
                Image(systemName: "person.circle.fill") // Default image if no URL
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .padding(.trailing, 8)
            }

            // Warning Details
            VStack(alignment: .leading) {
                if let username = warning.username {
                    Text(username) // Show the username of the warned user
                        .font(.headline)
                        .padding(.bottom, 4)
                } else {
                    Text("Unknown User") // Fallback if the username isn't available
                        .font(.headline)
                        .padding(.bottom, 4)
                }

                Text("Reason: \(warning.reason)")
                    .font(.subheadline)
                    .padding(.bottom, 4)

                Text("Warning Type: \(warning.warningtype)")
                    .font(.subheadline)
                    .padding(.bottom, 4)

                Text("Issued by: \(warning.issuewarnby)")
                    .font(.subheadline)
                    .padding(.bottom, 4)

                Text("Issued On: \(warning.createdon)")
                    .font(.subheadline)
            }
        }
        .padding(.vertical, 4) // Padding for the whole row
        .background(Color.white) // Optional: set background color
    }
}
