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
    
    @Published var reportCount: Int = 0

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
    func fetchReportCount(completion: @escaping (Result<Int, Error>) -> Void) {
           reference.child(collectionName).observeSingleEvent(of: .value) { snapshot in
               let count = Int(snapshot.childrenCount)
               self.reportCount = count // Update the published property
               completion(.success(count))
           } withCancel: { error in
               completion(.failure(error))
           }
       }
   }
