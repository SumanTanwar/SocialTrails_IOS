//
//  ViewProfileView.swift
//  SocialTrailsApp
//
//  Created by Suman Tanwar on 2024-10-11.
//

import SwiftUI

struct ViewProfileView: View {
    
    @StateObject private var userService = UserService()
    @State public var userId: String
    @State private var username: String = "User"
    @State private var email: String = ""
    @State private var bio: String = ""
    @State private var postsCount: Int = 0
    @State private var followersCount: Int = 0
    @State private var followingsCount: Int = 0
    @ObservedObject private var sessionManager = SessionManager.shared
    
    init(userId: String = SessionManager.shared.getCurrentUser()?.id ?? "") { // Default to current user ID
           self.userId = userId
       }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack{
                VStack{
                    Image("user")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .cornerRadius(40)
                    
                    if let currentUser = sessionManager.getCurrentUser() {
                        Text(currentUser.username)
                            .font(.system(size: Utils.fontSize16))
                            .foregroundStyle(Utils.blackListColor)
                            .padding(.leading, 10)
                    } else {
                        Text("Unknown User")
                            .font(.system(size: Utils.fontSize16))
                            .foregroundStyle(Utils.blackListColor)
                            .padding(.leading, 10)
                    }
                }
                VStack(alignment: .leading) {
                    HStack {
                        VStack{
                            Text("\(postsCount) ")
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                        
                            Text("Posts")
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                           
                        }.padding(.leading, 15)
                       
                        VStack{
                            Text("\(followersCount) ")
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                        
                            Text("Followers")
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                           
                        } .padding(.leading, 20)
                        
                         VStack{
                             Text("\(followingsCount) ")
                                 .font(.system(size: 14))
                                 .foregroundColor(.black)
                         
                             Text("Followings")
                                 .font(.system(size: 14))
                                 .foregroundColor(.black)
                            
                         } .padding(.leading, 20)
                    }
                }
               
            }
            Text(sessionManager.getCurrentUser()?.bio ?? "")
                .font(.system(size: 12))
                .foregroundColor(.black)
                .padding(.leading, 10)
            NavigationLink(destination: EditProfileView()) {
                Text("Edit Profile")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity,maxHeight: 35)
                    .background(Color.purple)
                    .cornerRadius(10)
                    .padding(.horizontal, 10)
            }
            .padding(.vertical, 5)
            Spacer()
        }.padding(.top,20)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}
struct ViewProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ViewProfileView()
    }
}

