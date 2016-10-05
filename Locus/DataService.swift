//
//  DataService.swift
//  Locus
//
//  Created by Andre Suhartanto on 9/26/16.
//  Copyright © 2016 EndeJeje. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct DataService {
    static var rootRef = FIRDatabase.database().reference()
    static var usersRef = FIRDatabase.database().reference().child("users")
    static var placesRef = FIRDatabase.database().reference().child("Place")
    
    
}


