//
//  AdminModeratorListView.swift
//  SocialTrailsApp
//
//  Created by Barsha Roka on 2024-10-08.
//

import SwiftUI
import Firebase

struct AdminModeratorListView: View {
    @State private var moderatorsList: [Users] = [] 
    @State private var isLoading = true
    private let userService = UserService()

    var body: some View {
        NavigationView {
            VStack {
                Text("Moderators List")  
                                   .font(.largeTitle)
                                   .padding()
                
                if isLoading {
                    ProgressView("Loading moderators...")
                } else if moderatorsList.isEmpty {
                    Text("No moderators found.")
                } else {
                    List(moderatorsList, id: \.userId) { moderator in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(moderator.username)
                                    .font(.headline)
                                Text(moderator.email)
                                    .font(.subheadline)
                            }
                            Spacer()
                            Button(action: {
                                deleteModerator(moderator.userId)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .navigationBarTitle("Moderators", displayMode: .inline)
            .onAppear {
                loadModeratorList()
            }
            Spacer()
        }
    }

    private func loadModeratorList() {
        isLoading = true
        userService.getModeratorList { result in
            switch result {
            case .success(let moderators):
                moderatorsList = moderators
                isLoading = false
            case .failure(let error):
                print("Error loading moderators: \(error.localizedDescription)")
                isLoading = false
            }
        }
    }

    private func deleteModerator(_ userId: String) {
        userService.deleteProfile(userId) { result in
            switch result {
            case .success:
                print("Moderator deleted successfully")
                loadModeratorList()  // Refresh list after deletion
            case .failure(let error):
                print("Failed to delete moderator: \(error.localizedDescription)")
            }
        }
    }
}
