import SwiftUI
import GoogleMaps
import GooglePlaces

struct AdminPostDetailView: View {
    var postDetailId: String
    @State private var userPost: UserPost?
    @State private var comments: [PostComment] = []
    @State private var likes: [PostLike] = []
    @State private var showingDeleteAlert = false
    @State private var navigateToUserManage = false
    @State private var userId: String?
    @State private var showMapView = false
    @State private var isModerator: Bool = false
    @ObservedObject private var sessionManager = SessionManager.shared
    @StateObject private var reportService = ReportService()
    @State private var reporterNameText: String = ""
    @State private var reasonText: String = ""
    @State private var statusText: String = ""
    @State private var reportDateText: String = ""
    @State private var reviewedByText: String = ""
    @State private var actionTakenByText: String = ""
    @State private var actionTakenByShowText = false
    @State private var reportprofileImageURL: String?
    @State private var isReviewedButtonVisible = false
    @State private var isActionButtonVisible = false
    var reportId: String
    
    var body: some View {
        VStack {
            if let post = userPost {
                ScrollView {
                    VStack(alignment: .leading, spacing: 5) {
                        HStack() {
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
                        }
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
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack {
                            HStack {
                                Image(systemName: post.likecount ?? 0 > 0 ? "heart.fill" : "heart")
                                    .resizable()
                                    .frame(width: 18, height: 18)
                                    .foregroundColor(post.isliked ?? false ? .red : .gray)

                                Text("\(post.likecount ?? 0)")
                                    .font(.subheadline)
                            }

                           
                            HStack {
                                Image(systemName: "message")
                                    .resizable()
                                    .frame(width: 18, height: 18)

                                Text("\(post.commentcount ?? 0)")
                                    .font(.subheadline)
                            }
                        }

                        Text(Utils.getRelativeTime(from: post.createdon))
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                      

                        if let likeCount = post.likecount, likeCount > 0 {
                            Divider()
                            Text("Likes")
                                .font(.headline)
                                .bold()
                                
                            Divider()
                            PostLikesList(postId: post.postId, onLikesUpdated: { updatedCount in
                                self.userPost?.likecount = updatedCount
                            })
                        }
                       
                        if let commentCount = post.commentcount, commentCount > 0 {
                            Divider()
                            Text("Comments")
                                .font(.headline)
                                .bold()
                               
                            Divider()
                            AdminPostCommentView(postId: post.postId, onCommentUpdated: { updatedCount in
                                print("updaate count of commentt \(updatedCount)")
                                updateCommentCount(to: updatedCount)
                            })
                        }
                        
                        if !reportId.isEmpty {
                             VStack(alignment: .leading, spacing: 5) {
                                 Divider().padding(.top, 5)
                                 
                                 Text("Report")
                                     .font(.system(size: 18, weight: .bold))
                                     .padding(.top, 5)
                                     .frame(maxWidth: .infinity, alignment: .center)
                                 
                                 Divider()
                                 
                                 VStack(alignment: .leading) {
                                     Text("Reported By")
                                         .font(.system(size: 16, weight: .bold))
                                         .padding(.bottom, 5)
                                     
                                     HStack(alignment: .top, spacing: 8) {
                                         
                                         if let url = reportprofileImageURL, let imageUrl = URL(string: url) {
                                             AsyncImage(url: imageUrl) { image in
                                                 image
                                                     .resizable()
                                                     .aspectRatio(contentMode: .fill)
                                                     .frame(width: 80, height: 80)
                                                     .clipShape(Circle())
                                                     .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                                             } placeholder: {
                                                 Image(systemName: "person.circle.fill")
                                                     .resizable()
                                                     .scaledToFit()
                                                     .frame(width: 80, height: 80)
                                                     .foregroundColor(Color(.systemGray4))
                                                     .clipShape(Circle())
                                             }
                                         } else {
                                             Image(systemName: "person.circle.fill")
                                                 .resizable()
                                                 .scaledToFit()
                                                 .frame(width: 80, height: 80)
                                                 .foregroundColor(Color(.systemGray4))
                                                 .clipShape(Circle())
                                         }
                                         
                                        
                                         VStack(alignment: .leading) {
                                             Text(reporterNameText)
                                                 .font(.system(size: 16, weight: .bold))
                                             
                                             Text(reasonText)
                                                 .font(.system(size: 14))
                                             
                                             Text(statusText)
                                                 .font(.system(size: 14))
                                             
                                             if !isReviewedButtonVisible{
                                                 Text(reviewedByText)
                                                     .font(.system(size: 14))
                                             }
                                             
                                             if actionTakenByShowText {
                                                 Text(actionTakenByText)
                                                     .font(.system(size: 14))
                                             }
                                             
                                             Text(reportDateText)
                                                 .font(.system(size: 14))
                                             
                                             HStack {
                                                 if isReviewedButtonVisible {
                                                     Button("Review") {
                                                         startReviewedReport()
                                                     }
                                                     .frame(width: 120, height: 40)
                                                     .background(Color.blue)
                                                     .foregroundColor(.white)
                                                     .cornerRadius(5)
                                                 }
                                                 if isActionButtonVisible {
                                                     Button("Take Action") {
                                                         actionTakenForReport()
                                                     }
                                                     .frame(width: 120, height: 40)
                                                     .background(Color.green)
                                                     .foregroundColor(.white)
                                                     .cornerRadius(5)
                                                 }
                                             }
                                             .padding(.top, 8)
                                         }
                                     }
                                 }
                             }
                         }
                        
                        
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .navigationTitle("Post Details")
        .onAppear {
            fetchUserPostDetail()
            checkUserRole()
            getReportDetails()
           
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Confirm Delete"),
                message: Text("Are you sure you want to delete this post?"),
                primaryButton: .destructive(Text("Delete")) {
                    deletePost()
                },
                secondaryButton: .cancel()
            )
        }
        .toolbar {
            if !isModerator {
                            Button(action: { showingDeleteAlert.toggle() }) {
                                Text("Delete Post")
                            }
                        }
        }
        .background(
            NavigationLink(destination: AdminUserManageView(userId: userId ?? "",reportId: ""), isActive: $navigateToUserManage) {
                EmptyView()
            }
        )
        .sheet(isPresented: $showMapView) {
            if let latitude = userPost?.latitude, let longitude = userPost?.longitude {
             MapOnlyView(selectedLocation: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            }
        }
    }
    func getReportDetails() {
        reportService.fetchReportByReportedId(reportId: reportId) { result in
            switch result {
            case .success(let report):
                DispatchQueue.main.async {
                    print("report data : \(report.reason)")
                    self.reporterNameText = report.username ?? ""
                    self.reasonText = "Reason: \(report.reason)"
                    self.statusText = "Status: \(report.status)"
                    self.reportDateText = "Reported On: \(report.createdon)"
                    self.reviewedByText = "Reviewed By: \(report.reviewedby ?? "")"
                    self.actionTakenByText = "Action Taken By: \(report.actiontakenby ?? "")"
                    
                    self.isReviewedButtonVisible = report.reviewedby == nil || report.reviewedby!.isEmpty
                    self.actionTakenByShowText = report.actiontakenby != nil && !report.actiontakenby!.isEmpty
                    self.isActionButtonVisible = (report.reviewedby != nil && !report.reviewedby!.isEmpty) && (report.actiontakenby == nil || report.actiontakenby!.isEmpty)
                    
                    self.reportprofileImageURL = report.userprofilepicture ?? ""
                }
                
            case .failure(let error):
                print("Failed to fetch report: \(error.localizedDescription)")
            }
        }
    }

    func startReviewedReport() {
        let username = sessionManager.getCurrentUser()?.username ?? "Admin"
        reportService.startReviewedReport(reportId: reportId, reviewedBy: username) { result in
                switch result {
                case .success:
                    self.getReportDetails()
                case .failure(let errMessage):
                    print("Error: \(errMessage)")
                }
            }
        }
    func actionTakenForReport() {
        let username = sessionManager.getCurrentUser()?.username ?? "Admin"
        reportService.actionTakenReport(reportId: reportId,actionTakenBy: username) { result in
               switch result {
               case .success:
                   self.getReportDetails()
               case .failure(let errMessage):
                   print("Error: \(errMessage)")
               }
           }
       }
    private func checkUserRole() {
           let role = sessionManager.getCurrentUser()?.roleType
           isModerator = (role == UserRole.moderator.role)
       }
    private func fetchUserPostDetail() {
        UserPostService().getUserPostDetailById(postId: postDetailId) { result in
            switch result {
            case .success(let post):
                self.userPost = post
            case .failure(let error):
                print("Failed to fetch post details: \(error.localizedDescription)")
            }
        }
    }

  

    private func deletePost() {
        guard let userId = userPost?.userId else { return }
        UserPostService().deleteUserPost(postId: postDetailId) { result in
            switch result {
            case .success:
                print("Post deleted successfully")
                self.userId = userId
                self.navigateToUserManage = true
            case .failure(let error):
                print("Failed to delete post: \(error.localizedDescription)")
            }
        }
    }
    private func updateCommentCount(to newCount: Int) {
            if let post = userPost {
                post.commentcount = newCount
                // This line might help in refreshing the UI
                userPost = post
            }
        }
}
