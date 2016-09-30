//
//  User.swift
//  
//
//  Created by Bryan Lee on 27/09/2016.
//
//

import Foundation

class func currentUserUid() -> String? {
    return NSUserDefaults.standardUserDefaults().valueForKey("uid") as? String
}
