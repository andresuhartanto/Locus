//
//  FollowingSavedPlace.swift
//  
//
//  Created by Andre Suhartanto on 10/10/16.
//
//

import Foundation
import FirebaseDatabase
import GooglePlaces

class FollowingSavedPlace {
    var placeKey: String?
    var name: String?
    var placeID: String?
    var latitude: Double?
    var longitude: Double?
    var userUID: String?
    var createdAt: Double?
    
    init() {
        placeKey=""
        name=""
        placeID=""
        latitude=0.0
        longitude=0.0
        userUID=""
        createdAt=0.0
    }
    
    init?(snapshot: FIRDataSnapshot){
        guard let dict = snapshot.value as? [String: AnyObject] else {return nil}
        self.placeKey = snapshot.key
        
        
        
        if let dictName = dict["name"] as? String{
            self.name = dictName
        }else{
            self.name = ""
        }
        
        if let dictPlaceID = dict["placeID"] as? String{
            self.placeID = dictPlaceID
        }else{
            self.placeID = ""
        }
        
        if let dictUserUID = dict["userUID"] as? String{
            self.userUID = dictUserUID
        }else{
            self.userUID = ""
        }
        
        if let dictLatitude = dict["latitude"] as? Double{
            self.latitude = dictLatitude
        }else{
            self.latitude = 0.0
        }
        
        if let dictLongitude = dict["longitude"] as? Double{
            self.longitude = dictLongitude
        }else{
            self.longitude = 0.0
        }
        
        if let createdAt = dict["created_at"] as? Double {
            self.createdAt = createdAt
        } else {
            self.createdAt = 0.0
        }
        
        
        
        
    }
}
