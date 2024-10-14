//
//  UserPost.swift
//  SocialTrailsApp
//
//  Created by Admin on 10/3/24.
//

import Foundation
import UIKit

class UserPost: Decodable {
    var postId: String
    var userId: String
    var captiontext: String
    var createdon: String
    var updatedon: String?
    var location: String?
    var postdeleted: Bool
    var flagged: Bool?
    var moderationStatus: Bool?
    var imageUris: [UIImage]? // Keep as UIImage
    var uploadedImageUris: [String]?
    var latitude: Double?
    var longitude: Double?

    enum CodingKeys: String, CodingKey {
        case postId, userId, captiontext, createdon, updatedon, location, postdeleted, flagged, moderationStatus, uploadedImageUris, latitude, longitude, imageUris
    }

    // Initializer for creating a new post
    init(userId: String, captionText: String, imageUris: [UIImage], location: String?, latitude: Double?, longitude: Double?) {
        self.postId = UUID().uuidString // Generate a unique ID for new posts
        self.userId = userId
        self.captiontext = captionText
        self.createdon = Utils.getCurrentDatetime()
        self.imageUris = imageUris
        self.postdeleted = false
        self.location = location
        self.latitude = latitude
        self.longitude = longitude
    }

    // Required initializer for Decodable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        postId = try container.decode(String.self, forKey: .postId)
        userId = try container.decode(String.self, forKey: .userId)
        captiontext = try container.decode(String.self, forKey: .captiontext)
        createdon = try container.decode(String.self, forKey: .createdon)
        updatedon = try? container.decode(String.self, forKey: .updatedon)
        location = try? container.decode(String.self, forKey: .location)
        postdeleted = try container.decode(Bool.self, forKey: .postdeleted)
        flagged = try? container.decode(Bool.self, forKey: .flagged)
        moderationStatus = try? container.decode(Bool.self, forKey: .moderationStatus)
        uploadedImageUris = try? container.decode([String].self, forKey: .uploadedImageUris)
        latitude = try? container.decode(Double.self, forKey: .latitude)
        longitude = try? container.decode(Double.self, forKey: .longitude)

        // Decode image URIs (assuming these are stored as strings in your JSON)
        let imageUrlStrings = try? container.decode([String].self, forKey: .imageUris)
        imageUris = imageUrlStrings?.compactMap { urlString in
            // Here you should implement the logic to convert the URL string to UIImage.
            // This is just a placeholder function.
            return loadImage(from: urlString) // Implement this function
        }
    }

    // Placeholder function to load UIImage from a URL string
    private func loadImage(from urlString: String) -> UIImage? {
        guard let url = URL(string: urlString) else { return nil }
        if let data = try? Data(contentsOf: url) {
            return UIImage(data: data)
        }
        return nil
    }

    func toDictionary() -> [String: Any] {
        return [
            "postId": postId,
            "userId": userId,
            "captiontext": captiontext,
            "createdon": createdon,
            "location": location ?? "",
            "latitude": latitude ?? 0.0,
            "longitude": longitude ?? 0.0,
            "postdeleted": postdeleted
        ]
    }
}
