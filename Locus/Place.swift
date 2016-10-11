//
//  Place.swift
//  Locus
//
//  Created by Bryan Lee on 05/10/2016.
//  Copyright © 2016 EndeJeje. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Place: NSObject{
    var latitude: Double?
    var longitude: Double?
    var locality: String?
    var name: String?
    var placeID: String?
    var uid: String?
    var userUID: String?
    var photoRef: String?
    var username: String?
    var dateCreated: Double?
    var image: UIImage?
    
    init?(snapshot: FIRDataSnapshot){
        
        self.uid = snapshot.key
        
        guard let dict = snapshot.value as? [String: AnyObject] else {return nil}
        
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
        if let dictLocality = dict["locality"] as? String{
            self.locality = dictLocality
        }else{
            self.locality = ""
        }
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
        if let dictPhotoRef = dict["photoRef"] as? String{
            self.photoRef = dictPhotoRef
        }else{
            self.photoRef = ""
        }
        if let dictCreatedRef = dict["created_at"] as? Double{
            self.dateCreated = dictCreatedRef
        }else{
            self.dateCreated = 0.0
        }
        
    
    }
    
}
