//
//  Location.swift
//  Locus
//
//  Created by Bryan Lee on 06/10/2016.
//  Copyright © 2016 EndeJeje. All rights reserved.
//

import UIKit

class Location: NSObject {
    var name: String?
    var placeID: String?
    var image: UIImage?
    var dateCreated: Double?
    var photoRef: String?
    var cityName: String?
    var username: String?
    
    override init(){
        
        
    }

}

class PlaceType: NSObject {
    var location = [Place]()
    var image:UIImage?
    var photoRef: String?
    var cityName: String?
    
    override init(){
        
        
    }

}
