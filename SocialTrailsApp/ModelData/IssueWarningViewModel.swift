//
//  IssueWarningViewModel.swift
//  SocialTrailsApp
//
//  Created by Suman Tanwar on 2024-11-04.
//

import SwiftUI

class IssueWarningViewModel: ObservableObject {
    @Published var warnings: [IssueWarning] = [] // Holds the list of warnings
    private var warningService = IssueWarningService() // Instance of your service to fetch warnings

    // Function to fetch warnings
    func fetchIssueWarnings() {
        warningService.fetchWarnings { result in
            switch result {
            case .success(let fetchedWarnings):
                DispatchQueue.main.async {
                    self.warnings = fetchedWarnings // Update the warnings on the main thread
                }
            case .failure(let error):
                print("Error fetching warnings: \(error.localizedDescription)")
            }
        }
    }
}
