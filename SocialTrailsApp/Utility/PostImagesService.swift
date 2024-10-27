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
    
    func getAllPhotosByPostId(uid: String, completion: @escaping (Result<[String], Error>) -> Void) {

        reference.child(collectionName).queryOrdered(byChild: "postId").queryEqual(toValue: uid).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                var photosList: [PostImages] = []

                for childSnapshot in snapshot.children {
                    if let childData = childSnapshot as? DataSnapshot,
                       let photo = try? childData.data(as: PostImages.self) {
                        photosList.append(photo)
                    }
                }

                photosList.sort { $0.order < $1.order }

                let imageUrls: [String] = photosList.compactMap { $0.imagePath }

                completion(.success(imageUrls))
            } else {
                completion(.failure(NSError(domain: "PhotoErrorDomain", code: 404, userInfo: [NSLocalizedDescriptionKey: "Photos not found"])))
            }
        } withCancel: { error in
            completion(.failure(error))
        }
    }
    func deleteAllPostImages(postId: String, completion: @escaping (Result<Void, Error>) -> Void) {
           reference.child(collectionName)
               .queryOrdered(byChild: "postId")
               .queryEqual(toValue: postId)
               .observeSingleEvent(of: .value) { snapshot in
                   if snapshot.exists() {
                       let dispatchGroup = DispatchGroup()
                       var deleteErrors: [Error] = []

                       for childSnapshot in snapshot.children {
                           if let childData = childSnapshot as? DataSnapshot,
                              let photoPath = childData.childSnapshot(forPath: "imagePath").value as? String {
                               
                               dispatchGroup.enter()
                               self.deleteImageFromStorage(photoPath) { error in
                                   if let error = error {
                                       deleteErrors.append(error)
                                   }
                                   dispatchGroup.leave()
                               }

                               dispatchGroup.enter()
                               childData.ref.removeValue { error, _ in
                                   if let error = error {
                                       deleteErrors.append(error)
                                   }
                                   dispatchGroup.leave()
                               }
                           }
                       }

                       dispatchGroup.notify(queue: .main) {
                           if deleteErrors.isEmpty {
                               completion(.success(()))
                           } else {
                               completion(.failure(deleteErrors.first!))
                           }
                       }
                   } else {
                       completion(.failure(NSError(domain: "PhotoErrorDomain", code: 404, userInfo: [NSLocalizedDescriptionKey: "No photos found for this postId."])))
                   }
               } withCancel: { error in
                   completion(.failure(error))
               }
       }

       // Delete a specific image associated with a post
       func deleteImage(postId: String, photoPath: String, completion: @escaping (Result<Void, Error>) -> Void) {
           reference.child(collectionName).queryOrdered(byChild: "postId").queryEqual(toValue: postId).observeSingleEvent(of: .value) { snapshot in
               if snapshot.exists() {
                   for childSnapshot in snapshot.children {
                       if let snapshot = childSnapshot as? DataSnapshot,
                          let storedPostId = snapshot.childSnapshot(forPath: "postId").value as? String,
                          let storedPhotoPath = snapshot.childSnapshot(forPath: "imagePath").value as? String {

                           if storedPostId == postId && storedPhotoPath == photoPath {
                               let deleteGroup = DispatchGroup()

                               deleteGroup.enter()
                               snapshot.ref.removeValue { error, _ in
                                   if let error = error {
                                       completion(.failure(error))
                                   }
                                   deleteGroup.leave()
                               }

                               deleteGroup.enter()
                               self.deleteImageFromStorage(storedPhotoPath) { error in
                                   if let error = error {
                                       completion(.failure(error))
                                   }
                                   deleteGroup.leave()
                               }

                               deleteGroup.notify(queue: .main) {
                                   self.updatePhotoOrder(postId: postId) { result in
                                       switch result {
                                       case .success:
                                           completion(.success(()))
                                       case .failure(let error):
                                           completion(.failure(error))
                                       }
                                   }
                               }
                               return
                           }
                       }
                   }
                   completion(.failure(NSError(domain: "PhotoErrorDomain", code: 404, userInfo: [NSLocalizedDescriptionKey: "Photo path not found in the database."])))
               } else {
                   completion(.failure(NSError(domain: "PhotoErrorDomain", code: 404, userInfo: [NSLocalizedDescriptionKey: "Task failed. No photos found."])))
               }
           } withCancel: { error in
               completion(.failure(error))
           }
       }

       // Delete image from Firebase Storage
       private func deleteImageFromStorage(_ photoPath: String, completion: @escaping (Error?) -> Void) {
           let storageRef = Storage.storage().reference(forURL: photoPath)
         //  let storageRef = storageReference.child(photoPath)

           storageRef.delete { error in
               if let error = error {
                   print("Failed to delete image from Firebase Storage: \(error.localizedDescription)")
                   completion(error)
               } else {
                   print("Image deleted from Firebase Storage.")
                   completion(nil)
               }
           }
       }

       // Update the order of photos
       func updatePhotoOrder(postId: String, completion: @escaping (Result<Void, Error>) -> Void) {
           reference.child(collectionName)
               .queryOrdered(byChild: "postId")
               .queryEqual(toValue: postId)
               .observeSingleEvent(of: .value) { snapshot in
                   if !snapshot.exists() {
                       completion(.failure(NSError(domain: "PhotoErrorDomain", code: 404, userInfo: [NSLocalizedDescriptionKey: "No photos found for this postId."])))
                       return
                   }

                   var order = 1
                   let dispatchGroup = DispatchGroup()
                   var updateErrors: [Error] = []

                   for childSnapshot in snapshot.children {
                       if let snapshot = childSnapshot as? DataSnapshot {
                           dispatchGroup.enter()
                           snapshot.ref.child("order").setValue(order) { error, _ in
                               if let error = error {
                                   updateErrors.append(error)
                               }
                               dispatchGroup.leave()
                           }
                           order += 1
                       }
                   }

                   dispatchGroup.notify(queue: .main) {
                       if updateErrors.isEmpty {
                           completion(.success(()))
                       } else {
                           completion(.failure(updateErrors.first!))
                       }
                   }
               } withCancel: { error in
                   completion(.failure(error))
               }
       }
}
