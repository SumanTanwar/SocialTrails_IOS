import SwiftUI
import Firebase

struct NotificationsView: View {
    @State private var notifications: [Notification] = []
    @State private var isLoading: Bool = true
    @ObservedObject private var sessionManager = SessionManager.shared
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 0) {
          
            if isLoading {
                ProgressView("Loading notifications...")
                    .padding()
            } else if notifications.isEmpty {
                Text("No notifications available.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(notifications) { notification in
                            NavigationLink(destination: destinationView(for: notification)) {
                                NotificationRow(notification: notification)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            fetchNotifications()
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        
    }

    private func fetchNotifications() {
        let userId = sessionManager.getCurrentUser()?.id ?? ""
        let notificationService = NotificationService()
        notificationService.fetchNotifications(for: userId) { result in
            switch result {
            case .success(let fetchedNotifications):
                DispatchQueue.main.async {
                    self.notifications = fetchedNotifications
                    self.isLoading = false
                }
            case .failure(let error):
                print("Error fetching notifications: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }

    private func destinationView(for notification: Notification) -> some View {
        if notification.type.lowercased() == "post" {
            return AnyView(DashboardView())
        } else {
            return AnyView(FollowUnfollowView(userId: notification.relatedId))
        }
    }
}

struct NotificationRow: View {
    var notification: Notification

    var body: some View {
        HStack {
            if let url = notification.userProfilePicture, let imageUrl = URL(string: url) {
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
                            
                            Text("\(notification.username ?? "")\(notification.message)")
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading) 
                        }
                      
                       .padding(.leading, 5)
        }
        .padding(.vertical, 5)
    }
}
