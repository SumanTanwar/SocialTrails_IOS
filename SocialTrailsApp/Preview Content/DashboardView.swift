//
//  DashboardView.swift
//  SocialTrailsApp
//
//  Created by Admin on 9/30/24.
//

import SwiftUI

struct DashboardView: View {
    @ObservedObject private var sessionManager = SessionManager.shared
    @State private var navigateToSignIn: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
            
                if let currentUser = sessionManager.getCurrentUser() {
                    Text(currentUser.username)
                        .font(.title)
                        .padding(.leading, 10)
                } else {
                    Text("Unknown User")
                        .font(.title)
                        .padding(.leading, 10)
                }

                HStack {
                    Button(action: {
                        sessionManager.logoutUser()
                        navigateToSignIn = true
                    }) {
                        Text("Log Out")
                            .foregroundColor(.black)
                            .padding(.leading,10)
                    }
                    Spacer()
                }
                .padding()
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $navigateToSignIn) {
                SignInView() // Replace with your actual sign-in view
            }
        }
    }
}

#Preview {
    DashboardView()
}
