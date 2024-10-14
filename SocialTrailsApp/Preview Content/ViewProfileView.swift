import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct ViewProfileView: View {
    
    @StateObject private var userService = UserService()
    @State public var userId: String
    @State private var username: String = "User"
    @State private var email: String = ""
    @State private var bio: String = ""
    @State private var postsCount: Int = 0
    @State private var followersCount: Int = 0
    @State private var followingsCount: Int = 0
    @State private var profileImageUrl: String?
    @ObservedObject private var sessionManager = SessionManager.shared
    
    init(userId: String = SessionManager.shared.getCurrentUser()?.id ?? "") {
        self.userId = userId
    }
    
    var body: some View {
        NavigationStack{
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack {
                        if let url = profileImageUrl, let imageUrl = URL(string: url) {
                            AsyncImage(url: imageUrl) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(40)
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(Color(.systemGray4))
                            }
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundColor(Color(.systemGray4))
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
                
                Spacer()
            }
        }
        .padding(.top, 20)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear(perform: loadUserProfile)
    }
    
    private func loadUserProfile() {
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let document = snapshot, document.exists {
                if let data = document.data() {
                    self.username = data["username"] as? String ?? "User"
                    self.email = data["email"] as? String ?? ""
                    self.bio = data["bio"] as? String ?? ""
                    self.profileImageUrl = data["profileImageUrl"] as? String // Fetch profile image URL
                }
            } else {
                print("Document does not exist")
            }
        }
    }
}

struct ViewProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ViewProfileView()
    }
}
