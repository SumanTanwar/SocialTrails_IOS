import SwiftUI
import PhotosUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct EditProfileView: View {
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var bio: String = ""
    @State private var profileImageUrl: String?
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
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(Color(.systemGray4))
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
                        .onAppear {
                            username = currentUser.username
                        }
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
                
                if let currentBio = sessionManager.getCurrentUser()?.bio {
                    TextField("Bio", text: $bio)
                        .onAppear {
                            bio = currentBio
                        }
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
        profileImageUrl = currentUser.profilepicture
    }
    
    private func uploadProfileImage() {
        guard let selectedImage = viewModel.selectedItem else { return }
        
        Task {
            do {
                if let imageData = try await selectedImage.loadTransferable(type: Data.self),
                   let image = UIImage(data: imageData) {
                    
                    let storageRef = Storage.storage().reference().child("profile_images/\(sessionManager.getUserID()).jpg")
                    if let imageData = image.jpegData(compressionQuality: 0.8) {
                        _ = try await storageRef.putDataAsync(imageData)
                        let downloadURL = try await storageRef.downloadURL()
                        profileImageUrl = downloadURL.absoluteString
                    }
                }
            } catch {
                print("Error uploading image: \(error)")
            }
        }
    }

    private func saveProfile() {
        guard let currentUser = sessionManager.getCurrentUser() else { return }
        
        let updatedUser = Users(
            userId: currentUser.id,
            username: username,
            email: currentUser.email,
            bio: bio,
            profilepicture: profileImageUrl ?? currentUser.profilepicture, // Ensure this is set correctly
            roles: "",
            notification: currentUser.notification
        )
        
        userService.updateUser(updatedUser) { success in
            if success {
                sessionManager.updateUserInfo(username: username, bio: bio, profileImageUrl: profileImageUrl ?? currentUser.profilepicture)
                navigateToProfile = true
            } else {
                print("Error saving user profile.")
            }
        }
    }

  }

#Preview {
    EditProfileView()
}
