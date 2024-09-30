//
//  ContentView.swift
//  SocialTrailsApp
//
//  Created by Barsha Roka on 2024-09-25.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct ContentView: View {
    @State private var showSplashScreen = false
    @State private var selectedTab = 0
    @StateObject private var sessionManager = SessionManager.shared
    
    var body: some View {
        NavigationView {
            VStack {
                if sessionManager.isLoggedIn {
                    
                    DashboardView()
                    
                } else {
                    SignInView()
                        .opacity(showSplashScreen ? 0 : 1)
                }
                
                if showSplashScreen {
                    SplashScreenView()
                        .transition(.opacity)
                }
            }
            .background(Color.white.edgesIgnoringSafeArea(.all))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        showSplashScreen = false
                    }
                }
                checkAuthentication()
            }
        }
    }
    
    private func checkAuthentication() {
        if let user = Auth.auth().currentUser {
           
            sessionManager.loginUser(userid: user.uid) { success in
                if success {
                    print("User logged in: \(success)")
                } else {
                    print("Failed to fetch user details")
                  
                }
            }
        } else {
            // User is signed out
            sessionManager.logoutUser()
            print("No user logged in")
        }
    }

}

struct ContentView_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.colorScheme, .light) // Add environment settings if needed
    }
}
