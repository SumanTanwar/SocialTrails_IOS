import SwiftUI

struct AdminDashboardView: View {
    
    @State private var isLoggedOut = false
    
    @State private var numberOfUsers: String = "0"
    @State private var numberOfPosts: String = "0"
    @State private var numberOfReports: String = "0"
    @State private var userRole: String = ""
    
    
    @StateObject private var userService = UserService()
    @StateObject private var followService = FollowService()
    @StateObject private var reportService = ReportService()
    @StateObject private var userPostService = UserPostService()
    @ObservedObject private var sessionManager = SessionManager.shared


    
    
    var body: some View {
        NavigationStack {
            VStack {
                Text(userRole)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                    .padding()
                    .background(Color("background_color"))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 15)
                    .padding(.bottom, 10)
                
                Divider()
                    .background(Color.gray)
                
                HStack {
                    MetricSection(title: "Number of Users", value: numberOfUsers, imageName: "user")
                    MetricSection(title: "Number of Posts", value: numberOfPosts, imageName: "post")
                }
                .padding(.top, 10)
                
                HStack {
                    MetricSection(title: "Number of Reports", value: numberOfReports, imageName: "reports")
                    MetricSection(title: "Number of Warnings", value: "0", imageName: "warning") // Placeholder
                }
                .padding(.top, 10)
                
                Divider()
                    .background(Color.gray)
                
                Text("Leverage these metrics to make data-driven decisions, optimize your operations, and enhance user experience. Your admin dashboard is your central hub for overseeing platform performance and ensuring a smooth and efficient management process.")
                    .font(.system(size: 14))
                    .padding(.top, 12)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .frame(maxWidth: .infinity)
                
                Divider()
                    .background(Color.gray)
                
                Image("socialtrails_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding(.top, 10)
                
                Text("SocialTrails")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.purple)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 1)
            }
            .onAppear {
                fetchUserRole()
                getRegularUserList()
                getAllUserPost()
                fetchTotalReports()
            }
            .background(Color.white)
            .padding()
        }
    }
    
    private func fetchUserRole() {

        let role = sessionManager.getCurrentUser()?.roleType
        if role == UserRole.moderator.role {
            userRole = "MODERATOR"
         
        
        } else {
            userRole = "ADMIN"
        }
    }


    private func getRegularUserList() {
            userService.getRegularUserList { result in
                switch result {
                case .success(let users):
                    numberOfUsers = "\(users.count)"
                case .failure:
                    numberOfUsers = "0"
                }
            }
        }

    private func getAllUserPost() {
            userPostService.getPostCount { result in
                switch result {
                case .success(let count):
                    numberOfPosts = "\(count)"
                case .failure:
                    numberOfPosts = "0"
                }
            }
        }

    private func fetchTotalReports() {
        reportService.fetchReportCount { result in
            switch result {
            case .success(let count):
                numberOfReports = "\(count)"
            case .failure:
                numberOfReports = "0"
            }
        }
    }
}

struct MetricSection: View {
    var title: String
    var value: String
    var imageName: String
    
    var body: some View {
        VStack {
            Image(imageName)
                .resizable()
                .frame(width: 30, height: 30)
            
            Text(title)
                .font(.system(size: 14, weight: .bold))
            
            Text(value)
                .font(.system(size: 14, weight: .bold))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .shadow(radius: 4)
    }
}

struct AdminDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        AdminDashboardView()
    }
}
