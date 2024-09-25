//
//  SocialTrailsAppApp.swift
//  SocialTrailsApp
//
//  Created by Barsha Roka on 2024-09-25.
//

import SwiftUI

@main
struct SocialTrailsAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
