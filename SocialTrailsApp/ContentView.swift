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
    private let adminEmail = "socialtrails2024@gmail.com"
    
    var body: some View {
        NavigationView {
            VStack {
                if sessionManager.isLoggedIn {
                    Divider().background(Color.blue)
                    if sessionManager.getCurrentUser()?.roleType ==  UserRole.user.role {
                        BottomNavigationView(selectedTab: selectedTab) // Show Admin navigation
                                        } else {
                                            AdminBottomNavigationView(selectedTab: selectedTab) // Show user navigation
                                        }
                    
                    
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
            guard let userEmail = user.email?.lowercased() else {
                            print("No email found")
                            sessionManager.logoutUser()
                            return
                        }
                        print("Current user email: \(userEmail)")
            if userEmail == adminEmail.lowercased() {
                sessionManager.loginAdmin(userid: user.uid, email: userEmail) { success in
                    if success {
                        
                        print("User logged in: \(success)")
                    } else {
                        print("Failed to fetch user details")
                        
                    }
                }
            }
            else
            {
                
                sessionManager.loginUser(userid: user.uid) { success in
                    if success {
                        
                        print("User logged in: \(success)")
                    } else {
                        print("Failed to fetch user details")
                        
                    }
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
