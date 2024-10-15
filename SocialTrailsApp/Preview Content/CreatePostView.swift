//
//  CreatePostView.swift
//  SocialTrailsApp
//
//  Created by Admin on 10/1/24.
//
import SwiftUI

struct CreatePostView: View {
    @State private var caption: String = ""
    @State private var selectedLocation: String = "Tag Location"
    @State private var selectedImages: [UIImage] = []
    @State private var showingImagePicker: Bool = false
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""
    @ObservedObject private var sessionManager = SessionManager.shared
    @State private var showingChooseAddressView: Bool = false
    @State private var selectedLocationData: Location?
    @State private var navigateToSuccess: Bool = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack(spacing: 8) {
                    if let url = sessionManager.getCurrentUser()?.profilepicture, let imageUrl = URL(string: url) {
                        AsyncImage(url: imageUrl) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle()) // Clip the image to a circle
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(Color(.systemGray4))
                                .clipShape(Circle()) // Clip the placeholder to a circle as well
                        }
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color(.systemGray4))
                            .clipShape(Circle()) // Clip the default placeholder to a circle
                    }

                    
                    if let currentUser = sessionManager.getCurrentUser() {
                        Text(currentUser.username)
                            .font(.title)
                            .padding(.leading, 10)
                    } else {
                        Text("Unknown User")
                            .font(.title)
                            .padding(.leading, 10)
                    }
                }
                .padding(.top, 10)
                .frame(maxWidth: .infinity, alignment: .leading)

                TextEditor(text: $caption)
                    .frame(height: 150)
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                    .foregroundColor(.black)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, 5)

                Divider().background(Color.gray)

                HStack {
                    Image("location")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .onTapGesture {
                            showingChooseAddressView.toggle()
                        }
                    Text(selectedLocation)
                        .foregroundColor(.primary)
                        .italic()
                        .font(.subheadline)
                }
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if !selectedImages.isEmpty {
                    TabView {
                        ForEach(selectedImages.indices, id: \.self) { index in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: selectedImages[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: UIScreen.main.bounds.width, height: 180)
                                    .clipped()
                                
                                Button(action: {
                                    selectedImages.remove(at: index)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.red)
                                        .padding(10)
                                        .padding(.trailing, 10)
                                }
                            }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .frame(height: 180)
                }

                Divider().background(Color.gray)

                HStack {
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        Image("photo")
                            .resizable()
                            .frame(width: 35, height: 35)
                            .padding(8)
                    }

                    Spacer()

                    Button(action: {
                        postAction()
                    }) {
                        Image("share")
                            .resizable()
                            .frame(width: 35, height: 35)
                            .padding(8)
                    }
                    .padding(.trailing, 18)
                }
                .background(Color.gray.opacity(0.1))
                .padding(3)
                Spacer()
            }
            .padding(16)
            
           // .navigationTitle("Create Post")
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImages: $selectedImages)
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $showingChooseAddressView) {
                ChooseAddressView(show: $showingChooseAddressView, selectedLocation: $selectedLocationData)
                    .onDisappear {
                        if let location = selectedLocationData {
                            selectedLocation = location.address // Update the selected location text
                        }
                    }
            }
            .background(
                NavigationLink(destination: ViewProfileView(), isActive: $navigateToSuccess) {
                    EmptyView()
                }
            )
        }
    }

    private func showAlert(message: String) {
        alertMessage = message
        showingAlert = true
    }

    private func postAction() {
        let captiontxt = caption.trimmingCharacters(in: .whitespacesAndNewlines)
        if captiontxt.isEmpty {
            showAlert(message: "Caption is required.")
            return
        }
        if selectedLocationData == nil {
            showAlert(message: "Please tag the location.")
            return
        }
        if selectedImages.isEmpty {
            showAlert(message: "Please select a photo.")
            return
        }

        let userId = sessionManager.getCurrentUser()?.id ?? ""
        let userPost = UserPost(userId: userId, captionText: captiontxt, imageUris: selectedImages, location: selectedLocationData?.address, latitude: selectedLocationData?.latitude, longitude: selectedLocationData?.longitude)
        let userPostService = UserPostService()

        userPostService.createPost(userPost: userPost) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.navigateToSuccess = true
                }
            case .failure(_):
                alertMessage = "Create post failed! Please try again later."
                showingAlert = true
            }
        }
    }
}

struct CreatePostView_Previews: PreviewProvider {
    static var previews: some View {
        CreatePostView()
    }
}
