import SwiftUI

struct AdminReportListView: View {
    @StateObject private var reportService = ReportService()
    @State private var reportsWithUserInfo: [Report] = []
    @State private var selectedReportId: String?
    @State private var isPostDetailActive = false
    @State private var isUserProfileActive = false
    @State private var isWarningDialogActive = false

    var body: some View {
        NavigationView {
            VStack {
                List(reportsWithUserInfo, id: \.reportId) { report in
                    reportRow(report: report)
                }
                .onAppear(perform: fetchReports)
                .navigationTitle("Admin Reports")
                .font(.title)
                
                // Detail Section
            }
            .background(
                NavigationLink(
                    destination: AdminPostDetailView(postDetailId: selectedReportId ?? ""),
                    isActive: $isPostDetailActive
                ) {
                    EmptyView()
                }
            )
            .background(
                NavigationLink(
                    destination: AdminUserManageView(userId: selectedReportId ?? ""),
                    isActive: $isUserProfileActive
                ) {
                    EmptyView()
                }
            )
            
        }
    }

    private func reportRow(report: Report) -> some View {
        HStack {
            // Profile Image from report (if available)
            if let profilePictureURL = report.userprofilepicture, !profilePictureURL.isEmpty,
               let url = URL(string: profilePictureURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .padding(.trailing, 8)
                } placeholder: {
                    ProgressView()
                }
            } else {
                // Default person icon if no profile picture
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)
                    .clipShape(Circle())
                    .padding(.trailing, 8)
            }
           
            VStack(alignment: .leading) {
                Text(report.username ?? "Unknown") // Display username, if available
                    .font(.headline)
                Text(report.createdon)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Type: \(report.reporttype)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Status: \(report.status.rawValue)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
         
            // Eye icon to select the report
            Button(action: {
                            self.selectedReportId = report.reportedId
                            if report.reporttype == ReportType.post.rawValue {
                                self.isPostDetailActive = true
                            } else if report.reporttype == ReportType.user.rawValue {
                                self.isUserProfileActive = true
                            } else {
                                // Show a message if the report type is invalid
                                print("No valid action for this report type")
                            }
                        }) {
                            HStack{
                                Image(systemName: "eye")
                                    .foregroundColor(.blue)
                                    .padding()
                                 
                            }
                        }
                        
                        // Exclamation mark icon to open warning dialog
            Button(action: {
                          self.isWarningDialogActive.toggle()
                      }) {
                          Image(systemName: "exclamationmark.triangle.fill")
                              .foregroundColor(.blue)
                              .padding()
                      }
                    }
                }
                
    private func fetchReports() {
        reportService.fetchReports { result in
            switch result {
            case .success(let fetchedReports):
                self.reportsWithUserInfo = fetchedReports
            case .failure(let error):
                // Handle the error (e.g., show an alert)
                print("Error fetching reports: \(error)")
            }
        }
    }
}
