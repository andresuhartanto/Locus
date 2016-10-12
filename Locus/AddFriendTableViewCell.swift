//
//  AddFriendTableViewCell.swift
//  Locus
//
//  Created by Andre Suhartanto on 10/12/16.
//  Copyright © 2016 EndeJeje. All rights reserved.
//

import UIKit

class AddFriendTableViewCell: UITableViewCell {
    
    var checker: Bool = true
    var user: User!
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!

    @IBAction func followButtonPressed(sender: UIButton) {
        if checker{
            DataService.usersRef.child(User.currentUserUid()!).child("following").child(self.user.uid!).removeValue()
            DataService.usersRef.child(self.user.uid!).child("follower").child(User.currentUserUid()!).removeValue()
        }else{
            
            DataService.usersRef.child(User.currentUserUid()!).child("following").updateChildValues([self.user.uid!: true])
            DataService.usersRef.child(self.user.uid!).child("follower").updateChildValues([User.currentUserUid()!: true])
        }
        
    }

}
