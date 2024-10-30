//
//  SocialTrailsAppApp.swift
//  SocialTrailsApp
//
//  Created by Barsha Roka on 2024-09-25.
//

import SwiftUI
import Firebase
import GooglePlaces
import GoogleMaps

@main
struct SocialTrailsAppApp: App {
    init(){
        GMSServices.provideAPIKey("AIzaSyA0fTMwiCSxxNp18DLvIfmCEwF1F2FW1PU")
        GMSPlacesClient.provideAPIKey("AIzaSyA0fTMwiCSxxNp18DLvIfmCEwF1F2FW1PU")
        FirebaseApp.configure()
       
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                
        }
    }
}
