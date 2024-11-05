import SwiftUI

struct AdminReportListView: View {
    @StateObject private var reportService = ReportService()
    @State private var reportsWithUserInfo: [Report] = []
    @State private var showWarningPopup = false
    @State private var selectedReport: Report?
    @State private var issueWarnto = ""

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    ScrollView {
                        LazyVStack(alignment: .leading) {
                            ForEach(reportsWithUserInfo, id: \.reportId) { report in
                                reportRow(report: report)
                            }
                        }
                        .padding()
                    }
                    .onAppear(perform: fetchReports)
                    .navigationTitle("Admin Reports")
                    .font(.title)
                }

                // Overlay and Popup
                if showWarningPopup {
                    Color.black.opacity(0.4) // Dark overlay
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            showWarningPopup = false // Dismiss on tap
                        }

                    if let report = selectedReport {
                        WarningPopup(isPresented: $showWarningPopup, issueWarnId: report.reportedId, issueWarnto: issueWarnto, warningType: report.reporttype)
                            .transition(.scale) // Optional scale transition
                            .animation(.easeInOut) // Optional animation
                    }
                }
            }
        }
    }

    private func fetchUserPostDetail(for report: Report) {
        if report.reporttype == ReportType.post.rawValue {
            UserPostService().getUserPostDetailById(postId: report.reportedId) { result in
                switch result {
                case .success(let post):
                    issueWarnto = post.userId
                    selectedReport = report // Set selected report before showing popup
                    showWarningPopup = true
                case .failure(let error):
                    print("Failed to fetch post details: \(error.localizedDescription)")
                }
            }
        } else {
            issueWarnto = report.reportedId
            selectedReport = report // Set selected report before showing popup
            showWarningPopup = true
        }
    }

    private func reportRow(report: Report) -> some View {
        HStack {
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
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)
                    .clipShape(Circle())
                    .padding(.trailing, 8)
            }

            VStack(alignment: .leading) {
                Text(report.username ?? "Unknown")
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

            NavigationLink(destination: Group {
                if report.reporttype == "post" {
                    AdminPostDetailView(postDetailId: report.reportedId, reportId: report.reportId ?? "")
                } else {
                    AdminUserManageView(userId: report.reportedId, reportId: report.reportId ?? "")
                }
            }) {
                Image(systemName: "eye")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding()
            }

            Button(action: {
                fetchUserPostDetail(for: report)
            }) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding()
            }
        }
        .padding()
    }

    private func fetchReports() {
        reportService.fetchReports { result in
            switch result {
            case .success(let fetchedReports):
                self.reportsWithUserInfo = fetchedReports
            case .failure(let error):
                print("Error fetching reports: \(error)")
            }
        }
    }
}
