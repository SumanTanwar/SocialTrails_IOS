//
//  UserSettingView.swift
//  SocialTrailsApp
//
//  Created by Suman Tanwar on 2024-10-08.
//

import SwiftUI

struct UserSettingView: View {
    
    @ObservedObject var sessionManager = SessionManager.shared
      @State private var notificationsEnabled = true
    @State private var navigateToSignIn = false
    
    var body: some View {
     
        
        NavigationView{
            VStack {
                HStack{
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 80,height: 80)
                        .clipShape(Circle())
                    VStack(alignment: .leading){
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
                }
                .padding()
                
                Text("Manage your account information and preferences to personalize your experience.")
                   
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .padding(.leading, 10)
                
                
                
                
                Form {
                    Section(header: Text("My Settings")){
                        Toggle(isOn: $notificationsEnabled){
                            Text("Activate Notifications")
                        }
                        Button(action: {
                            // Change Password
                        }){
                            Text("Change Password")
                        }
                        Button(action: {
                            // Delete Profile
                        }){
                            Text("Delete Profile")
                        }
                        Button(action: {
                            sessionManager.logoutUser()
                            navigateToSignIn = true
                        }){
                            Text("Log Out")
                        }
                    }
                }
            }
        }
    }
}
      
struct UserSettingView_Previews: PreviewProvider {
    static var previews: some View {
        UserSettingView()
    }
}

