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
    var userProfile: String!
    var select:Bool = true
    var listOfImage = [UIImage]()
    var image: UIImage!

    
    
    let header = NSBundle.mainBundle().loadNibNamed("StaticHeader", owner: 0, options: nil)[0] as? StaticHeader
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigation()
        retrieveHeaderData()
        retrievePlaceData()
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
    
    func retrievePlaceData(){
        DataService.placesRef.observeEventType(.ChildAdded, withBlock: { placeSnapshot in
            if let place = Place(snapshot:placeSnapshot){
                DataService.usersRef.child(place.userUID!).observeSingleEventOfType(.Value, withBlock: {userSnapshot in
                    if let user = User(snapshot:userSnapshot){
                        place.userUID = user.userUID
                        self.listOfUser.append(place)
                        self.loadFirstPhotoForPlace(place.placeID!)
                        self.tableView.reloadData()
                    }
                })
            }
        })
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
        }else if segue.identifier == "LocationSegue"{
            let nextScene = segue.destinationViewController as! LocationViewController
            nextScene.image = self.image
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
        fusuma.hasVideo = false // If you want to let the users allow to use video.
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
    
    func loadFirstPhotoForPlace(placeID: String) {
        
        GMSPlacesClient.sharedClient().lookUpPhotosForPlaceID(placeID) { (photos, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.description)")
            } else {
                if let photos = photos?.results {
                    self.loadImageForMetadata(photos)
                }
            }
        }
    }
    
    func loadImageForMetadata(photoMetadata: [GMSPlacePhotoMetadata]) {
        
        for (index, photo) in photoMetadata.enumerate() where index < 1{
            GMSPlacesClient.sharedClient().loadPlacePhoto(photo, callback: { (photo, error) in
                if let error = error {
                    // TODO: handle the error.
                    print("Error: \(error.description)")
                } else {
                    self.listOfImage.append(photo!)
                    self.tableView.reloadData()
                }
            })
        }
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
        return listOfImage.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:StaticProfileCell = tableView.dequeueReusableCellWithIdentifier("ProfileCell") as! StaticProfileCell
        let image = listOfImage[indexPath.row]
        
        cell.profileImageView.image = image
        cell.profileImageView.layer.shadowOpacity = 0.7
        cell.profileImageView.layer.shadowRadius = 10.0
        
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let place = listOfUser[indexPath.row]
        self.userProfile = place.placeID
        let image = listOfImage[indexPath.row]
        self.image = image
        self.performSegueWithIdentifier("LocationSegue", sender: self)
    }
    
    

}
