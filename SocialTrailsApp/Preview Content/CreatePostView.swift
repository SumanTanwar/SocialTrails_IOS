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
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Image("user")
                    .resizable()
                    .frame(width: 48, height: 48)
                    .scaledToFit()
                
                Text("User Name")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .padding(.top, 24)
            .padding(.bottom, 8)

            TextEditor(text: $caption)
                .frame(height: 150)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                .foregroundColor(.black)
                .font(.body)
                .multilineTextAlignment(.leading)
                .padding(.bottom, 10)

            Divider()
                .background(Color.gray)

            HStack {
                Image("location")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .padding(.trailing, 10)

                Text(selectedLocation)
                    .foregroundColor(.primary)
                    .italic()
                    .font(.subheadline)
            }
            .padding(.vertical, 10)
            
            if !selectedImages.isEmpty {
                TabView {
                    ForEach(selectedImages.indices, id: \.self) { index in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: selectedImages[index])
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width, height: 250)
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
                .frame(height: 250)
            }

            Divider()
                .background(Color.gray)

            HStack {
                Button(action: {
                    showingImagePicker = true
                }) {
                    Image("photo")
                        .resizable()
                        .frame(width: 48, height: 48)
                        .padding(8)
                        .background(Color.white)
                        .cornerRadius(24)
                }

                Spacer()

                Button(action: {
                    postAction()
                }) {
                    Image("share")
                        .resizable()
                        .frame(width: 30, height: 48)
                        .padding(8)
                        .background(Color.white)
                        .cornerRadius(24)
                }
                .padding(.trailing, 16)
            }
            .background(Color.gray.opacity(0.1))
            .padding(3)
        }
        .padding(16)
        .background(Color("background_color"))
        .navigationTitle("Create Post")
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImages: $selectedImages)
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
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
        
        if selectedImages.isEmpty {
            showAlert(message: "Please select a photo.")
            return
        }
        
        let userId = sessionManager.getCurrentUser()?.id ?? ""
        let userPost = UserPost(userId: userId, captionText: captiontxt, imageUris: selectedImages)
        let userPostService = UserPostService()
        print("userr post service call")
        userPostService.createPost(userPost: userPost) { result in
            switch result {
            case .success:
                break
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
