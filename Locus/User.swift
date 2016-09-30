//
//  User.swift
//  
//
//  Created by Bryan Lee on 27/09/2016.
//
//

import Foundation
import FirebaseDatabase

class User{
    
    var uid: String?
    var username: String?
    var userUID: String?
    var profileImage: String?
    var backgroundImage: String?

    init?(snapshot: FIRDataSnapshot){
        
        self.uid = snapshot.key
        
        guard let dict = snapshot.value as? [String: AnyObject] else { return nil }
        
        if let dictCaption = dict["username"] as? String{
            self.username = dictCaption
        }else{
            self.username = ""
        }
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
        
    }
    
    class func signIn (uid: String){
        //storing the uid of the person in the phone's default settings.
        NSUserDefaults.standardUserDefaults().setValue(uid, forKeyPath: "uid")
        
    }
    
    class func isSignedIn() -> Bool {
        
        if let _ = NSUserDefaults.standardUserDefaults().valueForKey("uid") as? String{
            return true
        }else {
            return false
        }
        
    }
    class func currentUserUid() -> String? {
        return NSUserDefaults.standardUserDefaults().valueForKey("uid") as? String
    }
}
