import SwiftUI
import GoogleMaps
import GooglePlaces

struct UserPostEditView: View {
    @State public var postId: String
   
    @State private var postCaption: String = ""
    @State private var imageUrls: [String] = []
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""
    @ObservedObject private var sessionManager = SessionManager.shared
    @State private var selectedLocation: String = "Tag Location"
    @State private var showingChooseAddressView: Bool = false
    @State private var selectedLocationData: Location?
    @State private var navigateToDetailView: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                if let url = sessionManager.getCurrentUser()?.profilepicture, let imageUrl = URL(string: url) {
                    AsyncImage(url: imageUrl) { image in
                        image
                            .resizable()
                            .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    }
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .foregroundColor(Color(.systemGray4))
                }

                VStack(alignment: .leading) {
                    if let currentUser = sessionManager.getCurrentUser() {
                        Text(currentUser.username)
                            .font(.title)
                    } else {
                        Text("Unknown User")
                            .font(.title)
                    }
                    Button(action: { showingChooseAddressView.toggle() }) {
                        Text(selectedLocation)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.leading, 10)
            }
            .padding(.horizontal)

            ScrollView(.horizontal) {
                            HStack {
                                ForEach(imageUrls.indices, id: \.self) { index in
                                    ZStack(alignment: .topTrailing) {
                                        AsyncImage(url: URL(string: imageUrls[index])) { image in
                                            image.resizable()
                                                .scaledToFit()
                                                .frame(width: UIScreen.main.bounds.width, height: 180)
                                                .clipped()
                                        } placeholder: {
                                            Image("noimage")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: UIScreen.main.bounds.width, height: 180)
                                                .cornerRadius(10)
                                                .foregroundColor(.gray)
                                        }

                                        if imageUrls.count > 1 {
                                            Button(action: {
                                                removeImage(at: index)
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .resizable()
                                                    .frame(width: 25, height: 25)
                                                    .foregroundColor(.red)
                                                    .padding(5)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding()
                        }
            
            TextEditor(text: $postCaption)
                .frame(height: 150)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                .foregroundColor(.black)
                .font(.body)
                .multilineTextAlignment(.leading)
                .padding(.bottom, 5)

            
            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: 40)
                .background(Color.purple)
                .cornerRadius(10)
                .padding()

                Button("Done") {
                    validateAndUpdatePost()
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: 40)
                .background(Color.purple)
                .cornerRadius(10)
                .padding()
            }
        }
        .onAppear {
            fetchPostDetails()
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $showingChooseAddressView) {
            ChooseAddressView(show: $showingChooseAddressView, selectedLocation: $selectedLocationData)
                .onDisappear {
                    if let location = selectedLocationData {
                        selectedLocation = location.address
                    }
                }
        }
        .navigationDestination(isPresented: $navigateToDetailView) {
            UserPostsDetailView(selectedPostId: postId)
        }
        .padding()
    }
    
    private func fetchPostDetails() {
        let userPostService = UserPostService()
        userPostService.getPostByPostId(postId: postId) { result in
            switch result {
            case .success(let post):
                postCaption = post.captiontext
                imageUrls = post.uploadedImageUris ?? []
                if let location = post.location,
                   let latitude = post.latitude,
                   let longitude = post.longitude {
                    selectedLocationData = Location(address: location, latitude: latitude, longitude: longitude)
                    selectedLocation = location
                } else {
                    selectedLocationData = nil
                    selectedLocation = "Tag Location"
                }
            case .failure(let error):
                alertMessage = "Failed to fetch post details: \(error.localizedDescription)"
                showingAlert = true
            }
        }
    }

    private func validateAndUpdatePost() {
        let trimmedCaption = postCaption.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedCaption.isEmpty {
            alertMessage = "Caption is required."
            showingAlert = true
            return
        }
        
        if selectedLocationData == nil {
            alertMessage = "Please tag the location."
            showingAlert = true
            return
        }
        
        updatePost()
    }

    private func updatePost() {
        let userPost = UserPost(
            captionText: postCaption,
            location: selectedLocationData?.address,
            latitude: selectedLocationData?.latitude,
            longitude: selectedLocationData?.longitude
        )
        
        let userPostService = UserPostService()
        userPostService.updateUserPost(post: userPost) { result in
            switch result {
            case .success:
                navigateToDetailView = true
            case .failure(let error):
                alertMessage = "Update failed: \(error.localizedDescription)"
                showingAlert = true
            }
        }
    }

    private func removeImage(at index: Int) {
        let postImagesService = PostImagesService()
        
        postImagesService.deleteImage(postId: postId, photoPath: imageUrls[index]) { result in
            switch result {
            case .success:
                imageUrls.remove(at: index)
                print("Image deleted successfully.")
            case .failure(let error):
                print("Failed to delete image: \(error.localizedDescription)")
            }
        }
    }
}
