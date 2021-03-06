//
//  StaticFriendCell.swift
//  
//
//  Created by Bryan Lee on 29/09/2016.
//
//

import UIKit
import Foundation

class StaticFollowingCell: UITableViewCell {
    
    var checker:Bool = true
    var user:User!

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followingButton: UIButton!
    
    
    @IBAction func followingOnButtonPressed(sender: AnyObject) {
        if checker{
            DataService.usersRef.child(User.currentUserUid()!).child("following").child(self.user.uid!).removeValue()
            DataService.usersRef.child(self.user.uid!).child("follower").child(User.currentUserUid()!).removeValue()
        }else{
            
            DataService.usersRef.child(User.currentUserUid()!).child("following").updateChildValues([self.user.uid!: true])
            DataService.usersRef.child(self.user.uid!).child("follower").updateChildValues([User.currentUserUid()!: true])
        }
    }
}
