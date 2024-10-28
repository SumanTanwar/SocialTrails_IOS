//
//  UserPost.swift
//  SocialTrailsApp
//
//  Created by Admin on 10/3/24.
//

import Foundation
import UIKit

class UserPost: ObservableObject,Decodable,Identifiable {
    var postId: String
    var userId: String
    var captiontext: String
    var createdon: String
    var updatedon: String?
    var location: String?
    var flagged: Bool?
    var moderationstatus: Bool?
    var imageUris: [UIImage]?
    var uploadedImageUris: [String]?
    var latitude: Double?
    var longitude: Double?
    @Published var isliked: Bool?
    @Published var likecount: Int?
    @Published var commentcount: Int?
    var username: String?
    var userprofilepicture: String?
    
    enum CodingKeys: String, CodingKey {
        case postId, userId, captiontext, createdon, updatedon, location, postdeleted, flagged, moderationstatus, uploadedImageUris, latitude, longitude, imageUris,username,userprofilepicture,likecount
    }

    // Initializer for creating a new post
    init(userId: String, captionText: String, imageUris: [UIImage], location: String?, latitude: Double?, longitude: Double?) {
        self.postId = UUID().uuidString 
        self.userId = userId
        self.captiontext = captionText
        self.createdon = Utils.getCurrentDatetime()
        self.imageUris = imageUris
        self.location = location
        self.latitude = latitude
        self.longitude = longitude
    }
    init(captionText: String, location: String?, latitude: Double?, longitude: Double?) {
        self.createdon=""
        self.postId = ""
        self.userId = ""
        self.captiontext = captionText
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
            flagged = try? container.decode(Bool.self, forKey: .flagged)
            moderationstatus = try? container.decode(Bool.self, forKey: .moderationstatus)
            uploadedImageUris = try? container.decode([String].self, forKey: .uploadedImageUris)
            latitude = try? container.decode(Double.self, forKey: .latitude)
            longitude = try? container.decode(Double.self, forKey: .longitude)
            username = try? container.decode(String.self, forKey: .username)
        userprofilepicture = try? container.decode(String.self, forKey: .userprofilepicture)
            let imageUrlStrings = try? container.decode([String].self, forKey: .imageUris)
            imageUris = imageUrlStrings?.compactMap { urlString in
                return loadImage(from: urlString)
                
            }
        likecount = try? container.decode(Int.self, forKey: .likecount)
            
            isliked = false
            commentcount = 0
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
        
        ]
    }
    func toMapUpdate() -> [String: Any] {
        return [
            "captiontext": captiontext,
            "updatedon" : updatedon ?? "",
            "location": location ?? "",
            "latitude": latitude ?? 0.0,
            "longitude": longitude ?? 0.0,
        
        ]
    }
}
