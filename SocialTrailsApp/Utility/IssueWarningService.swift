import SwiftUI
import Foundation
import Firebase

class IssueWarningService: ObservableObject {
    private var reference: DatabaseReference
    private let collectionName = "issuewarning"
    private let userService = UserService()
    
    init() {
        self.reference = Database.database().reference()
    }

    func addWarning(data: IssueWarning, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let newItemKey = reference.child(collectionName).childByAutoId().key else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to generate a unique key."])))
            return
        }

        // Create a mutable copy of the data
        var warningData = data
        warningData.issuewarningId = newItemKey

        // Store the warning in Firebase
        reference.child(collectionName).child(newItemKey).setValue(warningData.toDictionary()) { error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func fetchWarnings(completion: @escaping (Result<[IssueWarning], Error>) -> Void) {
        reference.child(collectionName).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            guard let warningDicts = snapshot.value as? [String: [String: Any]] else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No warnings found."])))
                return
            }

            var warnings: [IssueWarning] = []
            let dispatchGroup = DispatchGroup()

            for (warningId, warningData) in warningDicts {
                var warning = IssueWarning(dictionary: warningData)
                warning.issuewarningId = warningId // Set the warning ID

                // Retrieve user details
                let userId = warning.issuewarnto

                dispatchGroup.enter()
                self.retrieveUserDetails(userId: userId) { userDetails, error in
                    if let userDetails = userDetails {
                        warning.username = userDetails.username
                        warning.userprofilepicture = userDetails.profilepicture
                    } else if let error = error {
                        print("Error retrieving user details: \(error.localizedDescription)")
                    }
                    warnings.append(warning)
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                completion(.success(warnings))
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

    func fetchWarningCount(completion: @escaping (Result<Int, Error>) -> Void) {
        reference.child(collectionName).observeSingleEvent(of: .value) { snapshot in
            let count = Int(snapshot.childrenCount)
            completion(.success(count))
        } withCancel: { error in
            completion(.failure(error))
        }
    }
}
