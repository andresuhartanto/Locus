//
//  UsersTableViewController.swift
//  Locus
//
//  Created by Bryan Lee on 03/10/2016.
//  Copyright © 2016 EndeJeje. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SDWebImage

class UsersTableViewController: UITableViewController, StaticUserHeaderDelegate, StaticButtonHeaderDelegate{

    var listOfUser = [User]()
    let header = NSBundle.mainBundle().loadNibNamed("StaticHeader", owner: 0, options: nil)[0] as? StaticHeader
    var userProfile: String!
    var select:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigation()
        retrieveData()
        self.header?.profileImage.userInteractionEnabled = false
        self.header?.backgroundImage.userInteractionEnabled = false 
    }
    
    func navigation(){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        self.navigationController!.view.backgroundColor = UIColor.clearColor()
        self.header?.profileImage.superview!.bringSubviewToFront((self.header?.profileImage)!)
        self.header?.profileImage.layer.cornerRadius = (self.header?.profileImage.frame.size.width)!/2
        self.header?.profileImage.layer.masksToBounds = true
        self.header?.profileImage.layer.borderWidth = 2.0
        self.header?.profileImage.layer.borderColor = UIColor.whiteColor().CGColor
        
    }
    
    func retrieveData(){
        guard let userProfileID = self.userProfile else {
            // show alert or force user to logout
            // so it can login again
            return
        }
        
        DataService.usersRef.child(userProfileID).observeSingleEventOfType(.Value, withBlock: { userSnapshot in
            if let user = User(snapshot: userSnapshot){
                self.header?.nameLabel.text = user.username
                if let userImageUrl = user.backgroundImage, userImageUrl2 = user.profileImage{
                    
                    let url = NSURL(string: userImageUrl)
                    let url2 = NSURL(string: userImageUrl2)
                    self.header?.backgroundImage.sd_setImageWithURL(url)
                    self.header?.profileImage.sd_setImageWithURL(url2)
                }
                
            }
            
        })
        
        guard let currentUserID = User.currentUserUid() else{
            return
        }
        
        DataService.usersRef.child(currentUserID).child("following").observeEventType(.Value, withBlock: { snapshot in

            if snapshot.hasChild(self.userProfile!){

                self.header?.followButtonPressed.backgroundColor = UIColor.greenColor()
                self.header?.followButtonPressed.setTitle("Following", forState: .Normal)
                self.select = false

            }else{
                self.header?.followButtonPressed.backgroundColor = UIColor.clearColor()
                self.header?.followButtonPressed.setTitle("Follow", forState: .Normal)
                self.header?.followButtonPressed.layer.cornerRadius = 5
                self.header?.followButtonPressed.layer.borderWidth = 1
                self.select = true
            }
        })
        DataService.usersRef.child(self.userProfile!).child("follower").observeEventType(.Value, withBlock: { snapshot in
            self.header?.followerCount.text = String(snapshot.childrenCount)
        })
        DataService.usersRef.child(self.userProfile!).child("following").observeEventType(.Value, withBlock: { snapshot in
            self.header?.followingCount.text = String(snapshot.childrenCount)
        })
        
    }
    
    func goToFollowerPage() {
        self.performSegueWithIdentifier("FollowerSegue", sender: self)
        
    }
    
    func goToFollowingPage() {
        self.performSegueWithIdentifier("FollowingSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "FollowingSegue"{
            let nextScene = segue.destinationViewController as! FollowingViewController
            nextScene.userProfile = self.userProfile
        }else if segue.identifier == "FollowerSegue"{
            let nextScene = segue.destinationViewController as! FollowerViewController
            nextScene.userProfile = self.userProfile
        }
    }
    
    func followButton(){
        
        if select, let userProfile = self.userProfile{
            DataService.usersRef.child(User.currentUserUid()!).child("following").updateChildValues([userProfile:true])
            DataService.usersRef.child(self.userProfile!).child("follower").updateChildValues([User.currentUserUid()!:true])
        }else{
        DataService.usersRef.child(User.currentUserUid()!).child("following").child(self.userProfile!).removeValue()
            DataService.usersRef.child(self.userProfile!).child("follower").child(User.currentUserUid()!).removeValue()
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        header?.userDelegate = self
        header?.buttonDelegate = self
        return header
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return header?.frame.height ?? 50
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell")
        cell?.textLabel?.text = "abc"
        return cell!
    }

}
