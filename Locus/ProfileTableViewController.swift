//
//  ProfileTableViewController.swift
//  
//
//  Created by Bryan Lee on 27/09/2016.
//
//

import UIKit
import FirebaseDatabase
import Fusuma
import FirebaseStorage
import SDWebImage
import GooglePlaces



class ProfileTableViewController: UITableViewController, StaticHeaderDelegate, FusumaDelegate, StaticUserHeaderDelegate {
    
    enum ImageSelected {
        case Background
        case Profile
    }
    
    var listOfUser = [Place]()
    var cameraShown:Bool = false
    var fusumaSetting: ImageSelected?
    var locality: String!
    var select:Bool = true
    var listOfLocation = [Location]()
    var image: UIImage!
    var myPlace = [Place]()
    var myPlaceType = [PlaceType]()
    var myCity = [String]()

    
    
    let header = NSBundle.mainBundle().loadNibNamed("StaticHeader", owner: 0, options: nil)[0] as? StaticHeader
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigation()
        retrieveHeaderData()
        retrieveCity()
        
//        checkIsMyPost()
        
        self.header?.followButtonPressed.hidden = true
        
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
        DataService.rootRef.child("usersLocalities").child(User.currentUserUid()!).observeEventType(.Value, withBlock: {snapshot in
            
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
        }
        
    }
    
    func removeOthersPost(){
        
        for (index,i) in self.myPlace.enumerate(){
            if i.userUID != User.currentUserUid(){
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
    

    func retrievePlaceData(){

//    guard let currentUserUID = User.currentUserUid() else{return}
//    
//    DataService.usersRef.child(currentUserUID).child("savedPlace").observeSingleEventOfType(.Value, withBlock: {userSnapshot in
//        
//        if userSnapshot.hasChildren(){
//            let keyArray = userSnapshot.value?.allKeys as! [String]
//                for key in keyArray{
//                    DataService.rootRef.child("userslocalities").child(key).observeSingleEventOfType(.Value, withBlock: {(snapshot) in
//                        if let place = Place(snapshot:snapshot){
//                            let location = Location.init()
//                            location.cityName = place.locality
//                                DataService.placesRef.observeEventType(.ChildAdded, withBlock: { placeSnapshot in
//                                    DataService.placesRef.child(placeSnapshot.key).child("photoRef").observeSingleEventOfType(.Value, withBlock: {snapshot in
//                                        if let place1 = Place(snapshot: snapshot){
//                                            location.photoRef = place1.photoRef
//                                            self.loadImage(location)
//                                            self.tableView.reloadData()
//                                        }
//                                    })
//                            })
//                        }
//                    })
//            }
//        }
//        })
        
        DataService.placesRef.observeEventType(.Value, withBlock: {placeSnapshot in
            let keyArray = placeSnapshot.value?.allKeys as! [String]
            for key in keyArray{
                DataService.placesRef.child(key).observeEventType(.Value, withBlock: {placeSnapshot2 in
                    if let place = Place(snapshot:placeSnapshot2){
                        
                        self.myPlace.append(place)
                        
                        self.removeOthersPost()
                    }
                })
            }
        })

    }
    func loadImage(location: Location){
        
        guard let photoRef = location.photoRef else { return }
        
        let url = NSURL(string:"https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(photoRef)&key=AIzaSyB7-LGkbhbQJR16q-CvK8_7eBlNNok9Shk")
        print(url)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let data = NSData(contentsOfURL: url!)
            dispatch_async(dispatch_get_main_queue(), {
                if data != nil{
                location.image = UIImage(data: data!)
                self.listOfLocation.append(location)
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    func retrieveHeaderData(){
        guard let currentUserID = User.currentUserUid() else {
            // show alert or force user to logout
            // so it can login again
            return
        }
        
        DataService.usersRef.child(currentUserID).observeSingleEventOfType(.Value, withBlock: { userSnapshot in
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
        
        DataService.usersRef.child(User.currentUserUid()!).child("follower").observeEventType(.Value, withBlock: { snapshot in
            self.header?.followerCount.text = String(snapshot.childrenCount)
        })
        DataService.usersRef.child(User.currentUserUid()!).child("following").observeEventType(.Value, withBlock: { snapshot in
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
            nextScene.userProfile = User.currentUserUid()
//        }else if segue.identifier == "LocationSegue"{
//            let nextScene = segue.destinationViewController as! LocationViewController
//            nextScene.image = self.image
        }else if segue.identifier == "FollowerSegue"{
            let nextScene = segue.destinationViewController as! FollowerViewController
            nextScene.userProfile = User.currentUserUid()
        }
    }
    
    func openFusuma(selectedImage: String) {
        
        if selectedImage == "profile"{
            fusumaSetting = ImageSelected.Profile
        }else if selectedImage == "background"{
            fusumaSetting = ImageSelected.Background
        }
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.hasVideo = false
        self.presentViewController(fusuma, animated: true, completion:nil)
        self.cameraShown = true
    }



    func fusumaImageSelected(image: UIImage) {
        if let setting = fusumaSetting{
            
            switch setting{
            case .Background:
                self.header?.backgroundImage.image = image
                UIApplication.sharedApplication().keyWindow!.bringSubviewToFront((self.header?.profileImage)!)

                let uniqueImageName = NSUUID().UUIDString
                let storageRef = FIRStorage.storage().reference().child("\(uniqueImageName).png")
                let selectedImage = UIImageJPEGRepresentation((self.header?.backgroundImage.image)!,0.5)!
                storageRef.putData(selectedImage, metadata: nil, completion: { (metadata, error) in
                    if error != nil{
                        print(error)
                        return
                    }
                    if let imageURL = metadata?.downloadURL()?.absoluteString, user = User.currentUserUid(){
                        
                    SDImageCache.sharedImageCache().storeImage(self.header?.backgroundImage.image, forKey: imageURL)
                    FIRDatabase.database().reference().child("users").child(user).updateChildValues(["backgroundImage":imageURL])
                    }
                })

            case .Profile:
                self.header?.profileImage.image = image
                self.header?.profileImage.layer.cornerRadius = (self.header?.profileImage.frame.size.width)!/2
                self.header?.profileImage.layer.masksToBounds = true
                self.header?.profileImage.layer.borderWidth = 2.0
                self.header?.profileImage.layer.borderColor = UIColor.whiteColor().CGColor

                
                let uniqueImageName = NSUUID().UUIDString
                let storageRef = FIRStorage.storage().reference().child("\(uniqueImageName).png")
                
                let selectedImage = UIImageJPEGRepresentation((self.header?.profileImage.image)!, 0.5)!
                storageRef.putData(selectedImage, metadata: nil, completion: { (metadata, error) in
                    if error != nil{
                        print(error)
                        return
                    }
                    
                    if let imageURL = metadata?.downloadURL()?.absoluteString, user = User.currentUserUid(){
                        
                    SDImageCache.sharedImageCache().storeImage(self.header?.profileImage.image, forKey: imageURL)
                    FIRDatabase.database().reference().child("users").child(user).updateChildValues(["profileImage":imageURL])
                    }
                })
            }
        }
    }
    
    
    
    // Return the image but called after is dismissed.
    func fusumaDismissedWithImage(image: UIImage) {
        
        print("Called just after FusumaViewController is dismissed.")
        
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: NSURL) {
        
        print("Called just after a video has been selected.")
    }
    
    // When camera roll is not authorized, this method is called.
    func fusumaCameraRollUnauthorized() {
        
        print("Camera roll unauthorized")
    }
    
    func fusumaClosed() {
        
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            header?.delegate = self
            header?.userDelegate = self
            return header

    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return header?.frame.height ?? 50
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myPlaceType.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileCell") as! StaticProfileCell
        
        let placeType = self.myPlaceType[indexPath.row]
        
//        cell.profileImageView.image = placeType.image
//        cell.profileImageView.layer.shadowOpacity = 0.7
//        cell.profileImageView.layer.shadowRadius = 10.0
        cell.cityNameLabel.text = placeType.cityName
        cell.cityNameLabel.textColor = UIColor.whiteColor()

        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let place = listOfLocation[indexPath.row]
        
        self.locality = place.photoRef

        self.performSegueWithIdentifier("PlaceSegue", sender: self)
    }
    
    

}







//    func checkIsMyPost(){
//        DataService.placesRef.observeEventType(.Value, withBlock: {userSnapshot in
//            let keyArray = userSnapshot.value?.allKeys as! [String]
//            for key in keyArray{
//                DataService.placesRef.child(key).observeEventType(.Value, withBlock: { userSnapshot2 in
//                    let keyArray2 = userSnapshot2.value?.allKeys as! [String]
//                    for key2 in keyArray2{
//                        let placeType = PlaceType.init()
//                        DataService.placesRef.child(key).child(key2).observeEventType(.Value, withBlock: {userSnapshot3 in
//
//                            if let userName = userSnapshot3.value!["userUID"] as? String{
//                                if userName == User.currentUserUid(){
//                                    self.myPlace.append(userSnapshot3.key)
//
//                                }
//                            }
//
//                            for i in self.myPlace{
//                                self.retrievePlaceData(i,placeType: placeType)
//                            }
//
//
//                        })
//
//                        self.loadPlaceImage(placeType, key: key)
//                    }
//
//                })
//            }
//        })
//    }

//    func loadPlaceImage(placeType: PlaceType, key: String){
//
//        DataService.placesRef.child(key).child("photoRef").observeSingleEventOfType(.Value, withBlock: {snapshot3 in
//            if let user = Place(snapshot: snapshot3){
//                placeType.photoRef = user.photoRef
//                self.loadImage(placeType)
//                self.tableView.reloadData()
//            }
//        })
//
//    }


// Retrivedata
//        DataService.placesRef.observeEventType(.ChildAdded, withBlock: { placeSnapshot in
//
//            DataService.placesRef.child(placeSnapshot.key).observeEventType(.Value, withBlock: {(snapshot) in
//                let location = Location.init()
//                if snapshot.hasChild(path){
//                    DataService.placesRef.child(placeSnapshot.key).child(path).observeSingleEventOfType(.Value, withBlock: {(snapshot2) in
//                        if let place = Place(snapshot:snapshot2){
//                            placeType.cityName = place.locality
//                            location.cityName = place.locality
//                            placeType.location.append(location)
//
//
//                        }
//                    })
//
//                }
//            })
//        })


//            DataService.placesRef.observeEventType(.ChildAdded, withBlock: { placeSnapshot in
//                DataService.placesRef.child(placeSnapshot.key).child(path).observeSingleEventOfType(.Value, withBlock: {(snapshot) in
//                if let place = Place(snapshot:snapshot){
//                    let location = Location.init()
//                    location.cityName = place.locality
//                    DataService.placesRef.child(placeSnapshot.key).child("photoRef").observeSingleEventOfType(.Value, withBlock: {snapshot2 in
//                        if let user = Place(snapshot: snapshot2){
//                            location.photoRef = user.photoRef
//                            self.loadImage(location)
//                            self.tableView.reloadData()
//                        }
//
//
//                    })
//                }
//
//            })
//
//        })
