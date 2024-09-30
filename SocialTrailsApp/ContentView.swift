//
//  ContentView.swift
//  SocialTrailsApp
//
//  Created by Barsha Roka on 2024-09-25.
//

import SwiftUI
struct ContentView: View {
    @State private var showSplashScreen = true
    
    
    var body: some View {
        NavigationView{
            ZStack {
                if showSplashScreen{
                    SplashScreenView()
                        .transition(.identity)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        showSplashScreen = false
                    }
                }
            }
           
           
        }
    }
    
   
}

struct ContentView_Preview : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
