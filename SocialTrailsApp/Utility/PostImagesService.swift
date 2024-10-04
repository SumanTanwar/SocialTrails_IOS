//
//  PostImagesService.swift
//  SocialTrailsApp
//
//  Created by Admin on 10/3/24.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import UIKit

class PostImagesService {
    private var reference: DatabaseReference
    private let collectionName = "postimages"
    private var storageReference: StorageReference
    
    init() {
        self.reference = Database.database().reference()
        self.storageReference = Storage.storage().reference()
    }

    func addPostPhotos(_ model: PostImages, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let newItemKey = reference.child(collectionName).childByAutoId().key else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to generate a unique key."])))
            return
        }
        
        model.imageId = newItemKey
        
        reference.child(collectionName).child(newItemKey).setValue(model.toDictionary()) { error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func uploadImages(postId: String, imageUris: [UIImage], completion: @escaping (Result<Void, Error>) -> Void) {
       
        let dispatchGroup = DispatchGroup()
        var uploadErrors: [Error] = []
        
        for (index, image) in imageUris.enumerated() {
            dispatchGroup.enter()
            
            let order = index + 1
            let fileReference = storageReference.child("postimages/\(postId)/\(UUID().uuidString).jpg")

            if let imageData = image.jpegData(compressionQuality: 0.8) {
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                
                fileReference.putData(imageData, metadata: metadata) { _, error in
                    if let error = error {
                        uploadErrors.append(error)
                        dispatchGroup.leave()
                        return
                    }
                
                    fileReference.downloadURL { result in
                        switch result {
                        case .success(let url):
                            let photo = PostImages(postId: postId, imagePath: url.absoluteString, order: order)
                            self.addPostPhotos(photo) { addResult in
                                switch addResult {
                                case .success:
                                    dispatchGroup.leave()
                                case .failure(let error):
                                    uploadErrors.append(error)
                                    dispatchGroup.leave()
                                }
                            }
                        case .failure(let error):
                            uploadErrors.append(error)
                            dispatchGroup.leave()
                        }
                    }
                }
            } else {
                uploadErrors.append(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data."]))
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if uploadErrors.isEmpty {
                completion(.success(()))
            } else {
                completion(.failure(uploadErrors.first!))
            }
        }
    }
}
