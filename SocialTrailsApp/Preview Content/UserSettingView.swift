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
    private var dividerView: some View {
        Divider()
            .background(.gray)
            .font(.system(size: 3))
    }
    private var topViewMsg: some View {
        Text("Manage your account information and preferences to personalize your experience.")
            .font(.system(size: Utils.fontSize16))
            .foregroundStyle(Utils.blackListColor)
            .padding(.leading, 10)
    }
    
    var body: some View {
        
        
        NavigationStack {
            VStack(alignment: .leading, spacing: 10)  {
                HStack(spacing: 20) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 80,height: 80)
                        .clipShape(Circle())
                        .padding()
                    
                    VStack(alignment: .leading) {
                        if let currentUser = sessionManager.getCurrentUser() {
                            Text(currentUser.username)
                                .font(.system(size: Utils.fontSize24))
                                .foregroundStyle(Utils.blackListColor)
                                .padding(.leading, 10)
                        } else {
                            Text("Unknown User")
                                .font(.system(size: Utils.fontSize24))
                                .foregroundStyle(Utils.blackListColor)
                                .padding(.leading, 10)
                        }
                    }
                }
                
                dividerView.padding(.horizontal, 10)
                
                topViewMsg
                
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    
                    
                    Text("My Settings")
                        .font(.system(size: Utils.fontSize20))
                        .foregroundStyle(Utils.blackListColor)
                        .fontWeight(.bold)
                    
                    
                    dividerView
                    
                    HStack {
                        
                        Toggle(isOn: $notificationsEnabled){
                            Text("Activate Notifications")
                                .foregroundStyle(Utils.blackListColor)
                                .font(.system(size: Utils.fontSize16))
                        }
                    }
                    
                    dividerView
                    
                    NavigationLink(destination: ChangePasswordView()){
                        Text("Change Password")
                            .foregroundStyle(Utils.blackListColor)
                            .font(.system(size: Utils.fontSize16))
                    }
                    
                    dividerView
                    
                    Button(action: {
                        // Delete Profile
                    }){
                        Text("Delete Profile")
                            .foregroundStyle(Utils.blackListColor)
                            .font(.system(size: Utils.fontSize16))
                    }
                    
                    dividerView
                    
                    Button(action: {
                        sessionManager.logoutUser()
                        navigateToSignIn = true
                    }){
                        Text("Log Out")
                            .foregroundStyle(Utils.blackListColor)
                            .font(.system(size: Utils.fontSize16))
                    }
                    
                    dividerView
                    
                }.padding()
                
                Spacer()
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
        }
    }
}

struct UserSettingView_Previews: PreviewProvider {
    static var previews: some View {
        UserSettingView()
    }
}

