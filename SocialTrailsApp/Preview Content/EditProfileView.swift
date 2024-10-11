import SwiftUI
import PhotosUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct EditProfileView: View {
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var bio: String = ""
    @State private var profileImages: [UIImage] = []
    @State private var imagePickerPresented = false
    @State private var navigateToProfile = false
    
    // SessionManager and UserService instances
    @ObservedObject var sessionManager = SessionManager.shared
    private var userService = UserService()
    
    var body: some View {
        NavigationStack {
            VStack {
                if let profileImage = profileImages.first {
                    Image(uiImage: profileImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                } else {
                    Image("user")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                }
                
                Text("Edit Profile")
                    .font(.headline)
                    .foregroundColor(.black)
                
                TextField("User Name", text: $username)
                    .padding(10)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                
                TextField("Email", text: $email)
                    .padding(10)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .disabled(true)
                
                TextField("Bio", text: $bio)
                    .padding(10)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                
                Button("Save") {
                    saveProfile()
                }
                .foregroundColor(.white)
                .padding(10)
                .frame(maxWidth: .infinity, maxHeight: 45)
                .background(Color.purple)
                .cornerRadius(10)
                .padding(.vertical, 15)
                
                NavigationLink(destination: ViewProfileView(userId: sessionManager.getCurrentUser()?.id ?? ""), isActive: $navigateToProfile) {
                    EmptyView()
                }

                Spacer()
            }
            .padding()
            .onAppear(perform: loadUserProfile)
            .sheet(isPresented: $imagePickerPresented) {
                ImagePicker(selectedImages: $profileImages)
            }
            .navigationBarItems(trailing: Button("Add Picture") {
                imagePickerPresented = true
            })
        }
    }
    
    private func loadUserProfile() {
        guard let currentUser = sessionManager.getCurrentUser() else { return }
        
        userService.fetchUserByUserID(withID: currentUser.id) { user in
            if let user = user {
                username = user.username
                email = user.email
                bio = user.bio
            }
        }
    }

    private func saveProfile() {
        guard let currentUser = sessionManager.getCurrentUser() else { return }

        userService.registerUser(_user: Users(userId: currentUser.id, username: username, email: currentUser.email, bio: bio, roles: "")) { success in
            if success {
                print("User profile updated successfully.")
                if let image = profileImages.first {
                    uploadProfileImage(image)
                }
                DispatchQueue.main.async {
                    navigateToProfile = true
                }
            } else {
                print("Error updating user profile.")
            }
        }
    }

    private func uploadProfileImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        let storageRef = Storage.storage().reference().child("profile_images/\(sessionManager.getCurrentUser()?.id ?? "default").jpg")
        
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                return
            }
            storageRef.downloadURL { url, error in
                if let url = url {
                    saveProfileImageUrl(url.absoluteString)
                }
            }
        }
    }

    private func saveProfileImageUrl(_ url: String) {
        let db = Firestore.firestore()
        guard let currentUser = sessionManager.getCurrentUser() else { return }
        
        db.collection("users").document(currentUser.id).updateData([
            "profileImageUrl": url
        ]) { error in
            if let error = error {
                print("Error saving profile image URL: \(error.localizedDescription)")
            } else {
                print("Profile image URL saved successfully.")
            }
        }
    }
}

#Preview {
    EditProfileView()
}
