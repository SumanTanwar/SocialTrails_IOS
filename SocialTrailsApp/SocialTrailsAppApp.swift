//
//  SocialTrailsAppApp.swift
//  SocialTrailsApp
//
//  Created by Barsha Roka on 2024-09-25.
//

import SwiftUI
import Firebase

@main
struct SocialTrailsAppApp: App {
    init(){
        FirebaseApp.configure()
       
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                
        }
    }
}
