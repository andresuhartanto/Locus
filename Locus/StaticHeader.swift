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
    //    func followerCount()
    //    func followingCount()
}
protocol StaticUserHeaderDelegate {
    func goToFollowingPage()
    func goToFollowerPage()
}
protocol StaticButtonHeaderDelegate{
    func followButton()
}

class StaticHeader: UIView{
    
    var imagePost:User!
    var delegate:StaticHeaderDelegate!
    var userDelegate: StaticUserHeaderDelegate!
    var buttonDelegate: StaticButtonHeaderDelegate!


    @IBOutlet weak var locationCount: UILabel!
    @IBOutlet weak var followingCount: UILabel!
    @IBOutlet weak var followerCount: UILabel!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followerLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!

    @IBOutlet weak var followButtonPressed: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(loadProfile))
        let backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(loadBackground))
        let followingTapGesture = UITapGestureRecognizer(target: self, action: #selector(followingTap))
        let followerTapGesture = UITapGestureRecognizer(target: self, action: #selector(followerTap))
        
        profileImage.addGestureRecognizer(tapGesture)
        profileImage.userInteractionEnabled = true
        
        backgroundImage.addGestureRecognizer(backgroundTapGesture)
        backgroundImage.userInteractionEnabled = true
        
        
        followingLabel.addGestureRecognizer(followingTapGesture)
        followingLabel.userInteractionEnabled = true
        
        followerLabel.addGestureRecognizer(followerTapGesture)
        followerLabel.userInteractionEnabled = true
        
    }
    
    func loadProfile(){
        self.delegate.openFusuma("profile")
        
    }
    
    func loadBackground(){
        self.delegate.openFusuma("background")
    }
    
    func followingTap(){
        self.userDelegate.goToFollowingPage()
    }
    func followerTap(){
        self.userDelegate.goToFollowerPage()
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
    
    @IBAction func followerOnPressedButton(sender: AnyObject) {
        self.buttonDelegate.followButton()
    }

    
}


