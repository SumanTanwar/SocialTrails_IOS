//
//  UserPostService.swift
//  SocialTrailsApp
//
//  Created by Admin on 10/3/24.
//

import Foundation
import FirebaseDatabase

class UserPostService {

    private var reference: DatabaseReference
    private let collectionName = "post"
    private let postImagesService = PostImagesService()

    init() {
        reference = Database.database().reference()
    }

    func createPost(userPost: UserPost, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let newItemKey = reference.child(collectionName).childByAutoId().key else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to generate a unique key."])))
            return
        }
        
        userPost.postId = newItemKey
        
        reference.child(collectionName).child(newItemKey).setValue(userPost.toDictionary()) { error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                if let imageUris = userPost.imageUris {
                    self.postImagesService.uploadImages(postId: newItemKey, imageUris: imageUris) { result in
                        switch result {
                        case .success:
                            completion(.success(()))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No images to upload."])))
                }
            }
        }
    }

}
