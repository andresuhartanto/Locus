//
//  StaticFollowerCell.swift
//  Locus
//
//  Created by Bryan Lee on 03/10/2016.
//  Copyright © 2016 EndeJeje. All rights reserved.
//

import UIKit
import Foundation

class StaticFollowerCell: UITableViewCell {

    var checker: Bool = true
    var user: User!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followerImage: UIImageView!
    @IBOutlet weak var followerButton: UIButton!
    
    
    
    
    @IBAction func followerOnButtonPressed(sender: AnyObject) {
        
        if checker{
            DataService.usersRef.child(User.currentUserUid()!).child("following").child(self.user.uid!).removeValue()
            DataService.usersRef.child(self.user.uid!).child("follower").child(User.currentUserUid()!).removeValue()
        }else{
            
            DataService.usersRef.child(User.currentUserUid()!).child("following").updateChildValues([self.user.uid!: true])
            DataService.usersRef.child(self.user.uid!).child("follower").updateChildValues([User.currentUserUid()!: true])
        }
    }

}
