//
//  BottomNaavigationView.swift
//  SocialTrailsApp
//
//  Created by Admin on 9/30/24.
//

import SwiftUI

struct BottomNavigationView: View {
    @State public var selectedTab: Int
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Image(systemName: "house")
                }
                .tag(0)
            DashboardView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    
                }
                .tag(1)
            
            CreatePostView()
                .tabItem {
                    Image(systemName: "plus.app")
                    
                }
                .tag(2)
            
            ViewProfileView()
                .tabItem {
                    Image(systemName: "person.circle.fill")
                    
                }
                .tag(3)
            
            UserSettingView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    
                }
                .tag(4)
        }
        .accentColor(.blue)
    }
}




struct ProfileView: View {
    var body: some View {
        Text("Profile View")
    }
}


