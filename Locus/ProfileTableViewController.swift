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



class ProfileTableViewController: UITableViewController,StaticHeaderDelegate, FusumaDelegate {
    
    enum ImageSelected {
        case Background
        case Profile
    }
    
    var listOfUser = [Profile]()
    var cameraShown:Bool = false
    var fusumaSetting: ImageSelected?
    
    let header = NSBundle.mainBundle().loadNibNamed("StaticHeader", owner: 0, options: nil)[0] as? StaticHeader
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigation()
        retrieveData()


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
        
            DataService.usersRef.child(User.currentUserUid()!).observeSingleEventOfType(.Value, withBlock: { userSnapshot in
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
        
    }
    
    func goToFriendPage() {
        self.performSegueWithIdentifier("FollowingSegue", sender: self)
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
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        header?.delegate = self
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
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileCell")
        cell?.textLabel?.text = "abc"
        return cell!
    }
}
