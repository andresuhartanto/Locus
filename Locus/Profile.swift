//
//  Profile.swift
//  Locus
//
//  Created by Bryan Lee on 27/09/2016.
//  Copyright © 2016 EndeJeje. All rights reserved.
//

import Foundation
import FirebaseDatabase


class Profile :NSObject {
    
    var uid:String?
    var profileImage: String?
    var backgroundImage: String?
    var username: String?
    var userUID:String?

    
    init?(snapshot: FIRDataSnapshot){
        
        self.uid = snapshot.key
        
        guard let dict = snapshot.value as? [String: AnyObject] else { return nil }
                
        if let dictProfile = dict["profileImage"] as? String{
            self.profileImage = dictProfile
        }else{
            self.profileImage = ""
        }
        if let dictBackground = dict["backgroundImage"] as? String{
            self.backgroundImage = dictBackground
        }else{
            self.backgroundImage = ""
        }
        if let dictUserUID = dict["userUID"] as? String{
            self.userUID = dictUserUID
        }else{
            self.userUID = ""
        }
        
    }
}