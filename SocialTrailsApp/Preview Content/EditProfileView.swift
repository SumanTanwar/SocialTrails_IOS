import SwiftUI
import PhotosUI
import FirebaseStorage

struct EditProfileView: View {
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var bio: String = ""
    @State private var profilePicture: String?
    
    @State private var navigateToProfile = false
    @StateObject var viewModel = ProfileViewModel()
    
    @ObservedObject var sessionManager = SessionManager.shared
    private var userService = UserService()
    
    var body: some View {
        NavigationStack {
            VStack {
                PhotosPicker(selection: $viewModel.selectedItem) {
                    if let profileImage = viewModel.profileImage {
                        profileImage
                            .resizable()
                            .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                    } else {
                        if let url = profilePicture, let imageUrl = URL(string: url) {
                            AsyncImage(url: imageUrl) { image in
                                image
                                    .resizable()
                                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                                    .foregroundColor(Color(.systemGray4))
                            }
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .foregroundColor(Color(.systemGray4))
                        }

                    }
                }
                .onChange(of: viewModel.selectedItem) { _ in
                    uploadProfileImage()
                }
                
                Text("Edit Profile")
                    .font(.headline)
                    .foregroundColor(.black)
                
                if let currentUser = sessionManager.getCurrentUser() {
                    TextField("User Name", text: $username)
                        .onAppear { username = currentUser.username }
                        .padding(10)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
                
                TextField("Email", text: Binding(
                    get: { sessionManager.getCurrentUser()?.email ?? "" },
                    set: { _ in }
                ))
                .padding(10)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .disabled(true)
                
                if let currentUser = sessionManager.getCurrentUser(){
                    TextField("Bio", text: $bio)
                        .onAppear { bio = currentUser.bio }
                        .padding(10)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
              
                
                Button(action: saveProfile) {
                    Text("Save")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: 40)
                        .background(Color.purple)
                        .cornerRadius(10)
                        .padding(.horizontal, 5)
                }
                .padding(.vertical, 12)
                
                NavigationLink(destination: ViewProfileView(), isActive: $navigateToProfile) {
                    EmptyView()
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Edit Profile")
            .onAppear {
                loadUserProfile()
            }
        }
    }
    
    private func loadUserProfile() {
        guard let currentUser = sessionManager.getCurrentUser() else { return }
        username = currentUser.username
        email = currentUser.email
        bio = currentUser.bio
        profilePicture = currentUser.profilepicture
    }
    
    private func uploadProfileImage() {
         guard let selectedImage = viewModel.selectedItem else { return }
         
         Task {
             do {
                 if let imageData = try await selectedImage.loadTransferable(type: Data.self),
                    let image = UIImage(data: imageData) {
                     
                     let compressedImageData = image.jpegData(compressionQuality: 0.8)!
                     try await userService.uploadProfileImage(userId: sessionManager.getUserID(), imageData: compressedImageData) { result in
                         switch result {
                         case .success(let url):
                             profilePicture = url
                         case .failure(let error):
                             print("Error uploading image: \(error)")
                         }
                     }
                 }
             } catch {
                 print("Error uploading image: \(error)")
             }
         }
     }

     private func saveProfile() {
         guard let currentUser = sessionManager.getCurrentUser() else { return }
         
         let newProfileImage = profilePicture ?? currentUser.profilepicture
         if username != currentUser.username || bio != currentUser.bio || newProfileImage != currentUser.profilepicture {
             userService.updateNameAndBio(userId: currentUser.id, bio: bio, username: username) { result in
                 switch result {
                 case .success:
                     sessionManager.updateUserInfo(username: username, bio: bio, profilepicture: newProfileImage)
                     navigateToProfile = true
                 case .failure(let error):
                     print("Error saving user profile: \(error)")
                 }
             }
         } else {
             navigateToProfile = true
         }
     }
 }

 #Preview {
     EditProfileView()
 }
