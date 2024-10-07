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
        GMSServices.provideAPIKey("AIzaSyBdmLSrq0OuQob_ZvkV6zh9sVS2FmnYo4o")
        GMSPlacesClient.provideAPIKey("AIzaSyBdmLSrq0OuQob_ZvkV6zh9sVS2FmnYo4o")
        FirebaseApp.configure()
       
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                
        }
    }
}
