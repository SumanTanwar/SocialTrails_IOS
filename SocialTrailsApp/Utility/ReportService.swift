//
//  ReportService.swift
//  SocialTrailsApp
//
//  Created by Admin on 10/28/24.
//

import Foundation
import FirebaseDatabase

class ReportService: ObservableObject {
    private var reference: DatabaseReference
    private let collectionName = "report"
    private let userService = UserService()
   

    init() {
        self.reference = Database.database().reference()
    }

    func addReport(data: Report, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let newItemKey = reference.child(collectionName).childByAutoId().key else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to generate a unique key."])))
            return
        }
        data.reportId = newItemKey
       
        reference.child(collectionName).child(newItemKey).setValue(data.toDictionary()) { error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func fetchReports(completion: @escaping (Result<[Report], Error>) -> Void) {
        reference.child(collectionName).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            guard let reportDicts = snapshot.value as? [String: [String: Any]] else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "no report found."])))
                return
            }

            var reports: [Report] = []
            let dispatchGroup = DispatchGroup()

            for (reportId, reportData) in reportDicts {
                var report = Report(dictionary: reportData)
                report.reportId = reportId

                // Retrieve user details
                let userId = report.reporterId

                dispatchGroup.enter()
                self.retrieveUserDetails(userId: userId) { userDetails, error in
                    if let userDetails = userDetails {
                        report.username = userDetails.username
                        report.userprofilepicture = userDetails.profilepicture
                    } else if let error = error {
                        print("Error retrieving user details: \(error.localizedDescription)")
                    }
                    reports.append(report) // Add report to the list after setting user details
                    dispatchGroup.leave()
                }
            }

            // Notify after all user info is fetched
            dispatchGroup.notify(queue: .main) {
                completion(.success(reports))
            }
        } withCancel: { error in
            completion(.failure(error)) // Handle cancellation error
        }
    }


    func retrieveUserDetails(userId: String, completion: @escaping (Users?, Error?) -> Void) {
        userService.getUserByID(uid: userId) { result in
            switch result {
            case .success(let user):
                completion(user, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }


    func fetchReportCount(completion: @escaping (Result<Int, Error>) -> Void) {
        reference.child(collectionName).observeSingleEvent(of: .value) { snapshot in
            let count = Int(snapshot.childrenCount)
           
            completion(.success(count))
        } withCancel: { error in
            completion(.failure(error))
        }
    }
}
