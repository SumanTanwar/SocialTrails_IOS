import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct ViewProfileView: View {
    
    @StateObject private var userService = UserService()
    @State private var username: String = "User"
    @State private var email: String = ""
    @State private var bio: String = ""
    @State private var postsCount: Int = 0
    @State private var followersCount: Int = 0
    @State private var followingsCount: Int = 0
    @State private var profilepicture: String?
    @ObservedObject private var sessionManager = SessionManager.shared
    @State private var userPosts: [UserPost] = []
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack {
                        if let url = profilepicture, let imageUrl = URL(string: url) {
                            AsyncImage(url: imageUrl) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle()) // Clip the image to a circle
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(Color(.systemGray4))
                                    .clipShape(Circle()) // Clip the placeholder to a circle as well
                            }
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundColor(Color(.systemGray4))
                                .clipShape(Circle()) // Clip the default placeholder to a circle
                        }

                        
                        if let currentUser = sessionManager.getCurrentUser() {
                            Text(currentUser.username)
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                                .padding(.leading, 10)
                        } else {
                            Text("Unknown User")
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                                .padding(.leading, 10)
                        }
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
                            
                            VStack {
                                Text("\(followersCount) ")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                                Text("Followers")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                            }.padding(.leading, 20)
                            
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
                
                Text(sessionManager.getCurrentUser()?.bio ?? "")
                    .font(.system(size: 12))
                    .foregroundColor(.black)
                    .padding(.leading, 10)
                
                NavigationLink(destination: EditProfileView()) {
                    Text("Edit Profile")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: 40)
                        .background(Color.purple)
                        .cornerRadius(10)
                        .padding(.horizontal, 10)
                }
                .padding(.vertical, 5)
                
                if !userPosts.isEmpty {
                    let columns = [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ]
                    
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(userPosts, id: \.postId) { post in
                            if let imageUrls = post.uploadedImageUris, let firstImageUrl = imageUrls.first {
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
                    .padding(.horizontal, 10)
                }
                
                Spacer()
            }
        }
        .padding(.top, 20)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear(perform: loadUserProfile)
    }
    
    private func loadUserProfile() {
        let userId = sessionManager.getCurrentUser()?.id ?? ""
        self.username = sessionManager.getCurrentUser()?.username as? String ?? "Unknown User"
        self.email = sessionManager.getCurrentUser()?.email as? String ?? ""
        self.bio = sessionManager.getCurrentUser()?.bio as? String ?? ""
        self.profilepicture = sessionManager.getCurrentUser()?.profilepicture as? String
        
        print("profile pictuer \(sessionManager.getCurrentUser())")
        UserPostService().getAllUserPosts(userId: userId) { result in
            switch result {
            case .success(let posts):
                self.userPosts = posts
                self.postsCount = posts.count
            case .failure(let error):
                print("Error fetching user posts: \(error.localizedDescription)")
            }
        }
    }
}

struct ViewProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ViewProfileView()
    }
}
