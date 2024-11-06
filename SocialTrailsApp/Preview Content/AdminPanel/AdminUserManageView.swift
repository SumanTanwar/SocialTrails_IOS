import SwiftUI

struct AdminUserManageView: View {
   
    @State public var userId: String
    @State private var username: String = "User"
    @State private var email: String = ""
    @State private var bio: String = ""
    @State private var postsCount: Int = 0
    @State private var followersCount: Int = 0
    @State private var followingsCount: Int = 0
    @State private var reason: String = ""
    @State private var showReason: Bool = false
    @State private var showDeleteText: Bool = false
    @State private var deleteText: String = ""
    @State private var isSuspended: Bool = false
    @State private var profiledeleted: Bool = false
    @State private var userprofiledeleted: Bool = false
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var userPosts: [UserPost] = []
    @State private var profilepicture: String?
    @ObservedObject private var sessionManager = SessionManager.shared
    @StateObject private var userService = UserService()
    @StateObject private var followService = FollowService()
    @StateObject private var userPostService = UserPostService()
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
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack {
                    if let url = profilepicture, let imageUrl = URL(string: url) {
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

                   
                        Text(username)
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .padding(.leading, 10)
                    
                }
                
                VStack(alignment: .leading) {
                    HStack {
                        VStack {
                            Text("\(postsCount) ")
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                            Text("Posts")
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                        }.padding(.leading, 15)
                        
                        NavigationLink(destination: FollowersListView(userId: userId)) {
                            VStack {
                                Text("\(followersCount) ")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                                Text("Followers")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                            }.padding(.leading, 20)
                        }
                        
                        NavigationLink(destination: FollowingsListView(userId: userId)) {
                            VStack {
                                Text("\(followingsCount) ")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                                Text("Followings")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                            }.padding(.leading, 20)
                        }
                    }
                }
            }
            .padding(.top, 10)

            Text(bio)
                .font(.system(size: 12))
                .foregroundColor(.black)
                .padding(.leading, 10)

            Text(email)
                .font(.system(size: 12))
                .foregroundColor(.black)
                .padding(.leading, 10)

            if userprofiledeleted {
                Text("User deleted own profile")
                    .font(.system(size: 12))
                    .padding(4)
                    .foregroundColor(.white)
                    .background(Color.red)
                    .cornerRadius(5)
            } else {
                if showReason {
                    Text("Suspended profile: \(reason)")
                        .font(.system(size: 12))
                        .padding(4)
                        .foregroundColor(.white)
                        .background(Color.orange)
                        .cornerRadius(5)
                }
                
                if showDeleteText {
                    Text(deleteText)
                        .font(.system(size: 12))
                        .padding(4)
                        .foregroundColor(.white)
                        .background(Color.red)
                        .cornerRadius(5)
                }
                
                if sessionManager.getCurrentUser()?.email.lowercased() == "socialtrails2024@gmail.com" {
                    HStack {
                        Button(action: {
                            if isSuspended {
                                adminUnSuspendProfile()
                            } else {
                                showSuspendDialog()
                            }
                        }) {
                            Text(isSuspended ? "UnSuspend Profile" : "Suspend Profile")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.black)
                                .cornerRadius(5)
                        }
                        .padding(.horizontal, 8)
                        
                        Button(action: {
                            if profiledeleted {
                                adminUnDeleteProfile()
                            } else {
                                adminDeleteProfile()
                            }
                        }) {
                            Text(profiledeleted ? "Activate Profile" : "Delete Profile")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.black)
                                .cornerRadius(5)
                        }
                        .padding(.horizontal, 8)
                    }
                    .padding(.top, 10)
                    
                }
            }
            
            // User Posts Section
            if !userPosts.isEmpty {
                let columns = [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ]
                
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach($userPosts, id: \.postId) { $post in
                        
                        if let imageUrls = post.uploadedImageUris, !imageUrls.isEmpty {
                           
                            if let firstImageUrl = imageUrls.first {
                                NavigationLink(destination: AdminPostDetailView(postDetailId: post.postId,reportId: "")) {
                                    AsyncImage(url: URL(string: firstImageUrl)) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 130, height: 130)
                                            .clipped()
                                            .cornerRadius(0)
                                            .overlay(RoundedRectangle(cornerRadius: 0)
                                                        .stroke(Color.gray, lineWidth: 1))
                                    } placeholder: {
                                        ProgressView()
                                            .frame(width: 130, height: 130)
                                            .background(Color.gray.opacity(0.2))
                                            .overlay(RoundedRectangle(cornerRadius: 0)
                                                        .stroke(Color.gray, lineWidth: 1))
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 17)
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
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .onAppear {
            fetchUserDetails()
            fetchUserPosts()
            getReportDetails()
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        Spacer()
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
    private func fetchUserDetails() {
        userService.adminGetUserByID(withID: userId) { userData in
            guard let userData = userData else {
                print("No user found")
                return
            }
            self.username = userData["username"] as? String ?? "Unknown User"
            self.email = userData["email"] as? String ?? ""
            self.bio = userData["bio"] as? String ?? ""
            self.isSuspended = userData["suspended"] as? Bool ?? false
            self.showDeleteText = userData["admindeleted"] as? Bool ?? false
            self.profiledeleted = userData["admindeleted"] as? Bool ?? false
            self.userprofiledeleted = userData["profiledeleted"] as? Bool ?? false
            self.showReason = userData["suspended"] as? Bool ?? false
            self.reason = userData["suspendedreason"] as? String ?? ""
            self.profilepicture = userData["profilepicture"] as? String ?? ""
            self.deleteText = "Deleted profile by admin on \(userData["admindeletedon"] as? String ?? "")"
            
            followService.getFollowCounts(for: userId, callback: self)
        }
    }

    // New method to fetch user posts
    private func fetchUserPosts() {
        userPostService.getAllUserPosts(userId: userId) { result in
            switch result {
            case .success(let posts):
                self.userPosts = posts
                self.postsCount = posts.count
            case .failure(let error):
                print("Error fetching user posts: \(error.localizedDescription)")
                showAlert(message: "Error fetching user posts: \(error.localizedDescription)")
            }
        }
    }

    private func showAlert(message: String) {
        alertMessage = message
        showingAlert = true
    }

    private func showSuspendDialog() {
        let alert = UIAlertController(title: "Suspend Profile", message: "Please provide a reason for suspending \(self.username)'s profile", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Reason for suspension"
        }
        alert.addAction(UIAlertAction(title: "Confirm", style: .default) { _ in
            if let reason = alert.textFields?.first?.text, !reason.isEmpty {
                self.reason = reason
                adminSuspendProfile()
            } else {
                showAlert(message: "Suspend reason is required.")
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
    }

    private func adminSuspendProfile() {
        let adminuserId = sessionManager.getCurrentUser()?.id ?? ""
        userService.suspendProfile(userId: userId, suspendedBy: adminuserId, reason: self.reason) { success in
            if success {
                self.isSuspended = true
                self.showReason = true
            } else {
                self.isSuspended = false
                self.reason = ""
                self.showReason = false
                showAlert(message: "Suspend profile failed! Please try again later.")
            }
        }
    }

    private func adminUnSuspendProfile() {
        userService.activateProfile(userId: userId) { success in
            if success {
                self.isSuspended = false
                self.reason = ""
                self.showReason = false
            } else {
                showAlert(message: "Activate profile failed! Please try again later.")
            }
        }
    }

    private func adminDeleteProfile() {
        userService.adminDeleteProfile(userId: userId) { success in
            if success {
                self.showDeleteText = true
                self.profiledeleted = true
                self.deleteText = "Deleted profile by admin on \(Utils.getCurrentDatetime())"
            } else {
                showAlert(message: "Delete profile failed! Please try again later.")
            }
        }
    }

    private func adminUnDeleteProfile() {
        userService.adminUnDeleteProfile(userId: userId) { success in
            if success {
                self.showDeleteText = false
                self.profiledeleted = false
                self.deleteText = ""
            } else {
                showAlert(message: "Activate profile failed! Please try again later.")
            }
        }
    }
}

extension AdminUserManageView: DataOperationCallback {
    func onSuccess(followersCount: Int, followingsCount: Int) {
        self.followersCount = followersCount
        self.followingsCount = followingsCount
    }

    func onFailure(_ error: String) {
        print(error)
    }
}

