//
//  AdminBottomNavigationView.swift
//  SocialTrailsApp
//
//  Created by Admin on 10/15/24.
//

import SwiftUI

struct AdminBottomNavigationView: View {
    @State public var selectedTab: Int
    
    var body: some View {
        TabView(selection: $selectedTab) {
            AdminDashboardView()
                .tabItem {
                    Image(systemName: "house")
                }
                .tag(0)
            AdminUserList()
                .tabItem {
                    Image(systemName: "person.circle")
                    
                }
                .tag(1)
           

            AdminReportListView()
                .tabItem {
                    Image(systemName: "exclamationmark.triangle")
                    
                }
                .tag(2)
          
           
            AdminDashboardView()
                .tabItem {
                    Image(systemName: "exclamationmark.triangle.fill")
                    
                }
                .tag(3)
            
            AdminSettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    
                }
                .tag(4)
        }
        .accentColor(.blue)
    }
}






