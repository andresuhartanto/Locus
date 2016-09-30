//
//  StaticHeader.swift
//  Locus
//
//  Created by Bryan Lee on 27/09/2016.
//  Copyright © 2016 EndeJeje. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol StaticHeaderDelegate {
    func openFusuma(selectedImage: String)
    func goToFriendPage()
}

class StaticHeader: UIView{
    
    var imagePost:Profile!
    var delegate:StaticHeaderDelegate!


    @IBOutlet weak var backgroundImage: UIImageView!

    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var followingLabel: UILabel!

    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(loadProfile))
        let backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(loadBackground))
        let followingTapGesture = UITapGestureRecognizer(target: self, action: #selector(followingTap))
        
        profileImage.addGestureRecognizer(tapGesture)
        profileImage.userInteractionEnabled = true
        
        backgroundImage.addGestureRecognizer(backgroundTapGesture)
        backgroundImage.userInteractionEnabled = true
        
        
        followingLabel.addGestureRecognizer(followingTapGesture)
        followingLabel.userInteractionEnabled = true
        
    }
    
    func loadProfile(){
        self.delegate.openFusuma("profile")
        
    }
    
    func loadBackground(){
        self.delegate.openFusuma("background")
    }
    
    func followingTap(){
        self.delegate.goToFriendPage()
    }
    
    @IBAction func onLogOutButtonPressed(sender: UIButton) {
        try! FIRAuth.auth()?.signOut()

        NSUserDefaults.standardUserDefaults().removeObjectForKey("userUID")
        
        
        goBackToLogin()
        
        }
    
    func goBackToLogin(){
        let appDelegateTemp = UIApplication.sharedApplication().delegate!
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let LogInViewController = storyboard.instantiateInitialViewController()
        appDelegateTemp.window?!.rootViewController = LogInViewController
    }
    

    @IBOutlet weak var followOnButtonPressed: UIButton!

    
}


