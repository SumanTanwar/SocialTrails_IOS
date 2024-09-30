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
            
            SignInView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    
                }
                .tag(1)
            
            DashboardView()
                .tabItem {
                    Image(systemName: "arrow.up.circle.fill")
                    
                }
                .tag(2)
            
            DashboardView()  
                .tabItem {
                    Image(systemName: "person.circle.fill")
                    
                }
                .tag(3)
            
            ProfileView()
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


