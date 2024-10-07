//
//  Location.swift
//  SocialTrailsApp
//
//  Created by Admin on 10/7/24.
//

import Foundation

class Location  : Decodable{
    var locationId: String?
   
    var address: String
    var latitude: Double
    var longitude: Double
    var createdOn: String?
    var updatedOn: String?
    init(address: String, latitude: Double, longitude: Double) {
           self.address = address
           self.latitude = latitude
           self.longitude = longitude
       }
}
