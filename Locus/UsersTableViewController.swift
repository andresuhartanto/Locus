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

    let header = NSBundle.mainBundle().loadNibNamed("StaticHeader", owner: 0, options: nil)[0] as? StaticHeader
    var userProfile: String!
    var select:Bool = true
    
    var myPlace = [Place]()
    var myPlaceType = [PlaceType]()
    var myCity = [String]()
    var savedPlace = [String]()
    var locality: String!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("there is an place id \(userProfile)")
        
        navigation()
        retrieveData()
        retrievePlaceData()
        retrieveCity()
        retrievedSavedPlace()
        
        self.header?.profileImage.userInteractionEnabled = false
        self.header?.backgroundImage.userInteractionEnabled = false
        
        if self.userProfile == User.currentUserUid(){
        self.header?.followButtonPressed.hidden = true
        }

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
    
    func retrieveCity(){
        DataService.rootRef.child("usersLocalities").child(self.userProfile).observeEventType(.Value, withBlock: {snapshot in
            
            self.myCity = snapshot.value?.allKeys as! [String]
            self.createPlaceType()
            self.retrievePlaceData()
            
        })
    }
    
    func createPlaceType(){
        
        for i in self.myCity{
            let placeType = PlaceType.init()
            placeType.cityName = i
            self.myPlaceType.append(placeType)
            self.retrievedImageForPlaceType()
        }
    }
    
    func retrievedImageForPlaceType(){
        
        for i in self.myPlaceType{
            DataService.placesRef.child(i.cityName!).child("photoRef").observeSingleEventOfType(.Value, withBlock: {snapshot in
                if let photoRef = snapshot.value!["photoRef"] as? String{
                    
                    i.photoRef = photoRef
                    self.loadImage()
                }
            })
        }
    }
    
    func removeOthersPost(){
        
        for (index,i) in self.myPlace.enumerate(){
            if i.userUID != self.userProfile{
                self.myPlace.removeAtIndex(index)
            }
        }
        self.filterCity()
    }
    
    func filterCity(){
        
        for i in self.myPlace{
            for x in self.myPlaceType{
                if i.locality == x.cityName{
                    x.location.append(i)
                }
            }
        }
    }
    
    func retrievedSavedPlace(){
        DataService.usersRef.child(self.userProfile!).child("savedPlace").observeEventType(.Value, withBlock: {userSnapshot in
            
            self.savedPlace = userSnapshot.value?.allKeys as! [String]
            
            self.retrievePlaceData()
        })
    }
    
    func retrievePlaceData(){
        
        DataService.placesRef.observeSingleEventOfType(.Value, withBlock: {placeSnapshot in
            let keyArray = placeSnapshot.value?.allKeys as! [String]
            
            for key in keyArray{
                for savedPlace in self.savedPlace{
                    DataService.placesRef.child(key).child(savedPlace).observeSingleEventOfType(.Value, withBlock: {snapshot in
                        if let place = Place(snapshot: snapshot){
                            self.myPlace.append(place)
                            self.removeOthersPost()
                            
                            self.tableView.reloadData()
                        }
                    })
                }
            }
        })
    }
    
    func loadImage(){
        
        for i in self.myPlaceType{
            guard let photoRef = i.photoRef else { return }
            let url = NSURL(string:"https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(photoRef)&key=AIzaSyB7-LGkbhbQJR16q-CvK8_7eBlNNok9Shk")

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                let data = NSData(contentsOfURL: url!)
                dispatch_async(dispatch_get_main_queue(), {
                    if data != nil{
                        i.image = UIImage(data: data!)
                        self.tableView.reloadData()
                    }
                })
            }
        }
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
        }else if segue.identifier == "PlaceSegue"{
            let nextScene = segue.destinationViewController as! ListOfPlacesViewController
            nextScene.titleName = self.locality
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
        return myPlaceType.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:StaticProfileCell = tableView.dequeueReusableCellWithIdentifier("UserCell") as!StaticProfileCell
        let place = myPlaceType[indexPath.row]
        
        cell.userImage.image = place.image
        cell.userImage.layer.shadowOpacity = 0.7
        cell.userImage.layer.shadowRadius = 10.0
        cell.userLabel.text = place.cityName
        cell.userLabel.textColor = UIColor.whiteColor()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let place = myPlaceType[indexPath.row]
        
        self.locality = place.cityName
        
        self.performSegueWithIdentifier("PlaceSegue", sender: self)
    }
    
    

}
