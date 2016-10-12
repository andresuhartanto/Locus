//
//  PlaceDetailViewController.swift
//  Locus
//
//  Created by Andre Suhartanto on 9/28/16.
//  Copyright © 2016 EndeJeje. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import FirebaseDatabase
import NVActivityIndicatorView
import JSSAlertView
import Alamofire
import SwiftyJSON
import SDWebImage

class PlaceDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NVActivityIndicatorViewable {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addresLabel: UILabel!
    @IBOutlet weak var BusinesshourLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UIButton!
    @IBOutlet weak var websiteLabel: UIButton!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var savedByCollectionView: UICollectionView!
    
    var place: GMSPlace?
    var images = [UIImage]()
    var defaultNavigationBar : UINavigationBar?
    var saved: Bool = false
    let aGMSGeocoder = GMSGeocoder()
    var aSavedPlace: SavedPlace?
    
    var followingUser = [User]()
    lazy var emptyLabel: UILabel = {
        let label = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
        label.text = "Not save by your friend"
        label.textAlignment = NSTextAlignment.Center
        
        return label
    }()
    var newSavedPlace: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = place?.name
        addresLabel.text = place?.formattedAddress
        BusinesshourLabel.text = "Open"
        phoneNumberLabel.setTitle(place?.phoneNumber, forState: .Normal)
        
        let rating = Double(place!.rating).roundToPlaces(2)
        
        ratingLabel.text = "\(rating)"
        
        
        
        let website = place?.website
        if website != nil{
            let websiteString = place?.website!.absoluteString
            websiteLabel.setTitle(websiteString, forState: .Normal)
            websiteLabel.userInteractionEnabled = true
        }else{
            websiteLabel.setTitle("Not Available", forState: .Normal)
            websiteLabel.userInteractionEnabled = false
        }
        
        loadFirstPhotoForPlace(place!.placeID)
        
        getSavedBy()
        
        self.savedByCollectionView.alwaysBounceVertical = true
        
        defaultNavigationBar = self.navigationController?.navigationBar
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        title = place?.name
        
        let image = getNavigationBarImageWith(0.0)
        self.navigationController?.navigationBar.setBackgroundImage(image, forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = image
        
        toggleBasedOnSaveState()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let image = getNavigationBarImageWith(0)
        self.navigationController?.navigationBar.setBackgroundImage(image, forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = image
    }
    
    func toggleBasedOnSaveState(){
        if saved {
            saveButton.setImage(UIImage(named: "Unsaved 1x"), forState: .Normal)
        } else if saved == false {
            saveButton.setImage(UIImage(named: "Save 1x"), forState: .Normal)
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView{
            return images.count
        }else{
            if self.followingUser.count == 0{
                self.savedByCollectionView.backgroundView = emptyLabel
                return 0
                
            } else {
                self.savedByCollectionView.backgroundView = nil
                return followingUser.count
            }
            
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if collectionView == self.collectionView{
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! ImageCollectionViewCell
            cell.imageView.image = images[indexPath.row]
            
            return cell
        }else{
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("userCell", forIndexPath: indexPath) as! SavedByCollectionViewCell
            let user = followingUser[indexPath.row]
            
            if let imageURL = user.profileImage{
                let url = NSURL(string: imageURL)
                cell.userProfileImage.sd_setImageWithURL(url, completed: { (image, error, cache, url) in
                    print("cellForItemAtIndexPath")
                    cell.layer.cornerRadius = cell.frame.size.width / 2
                })
            }
            
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if collectionView == self.collectionView{
            let width = self.view.frame.size.width
            let height = collectionView.frame.size.height
            return CGSizeMake(width, height)
        }else{
            print("sizeForItemAtIndexPath")
            let height = collectionView.frame.size.height
            return CGSizeMake(height, height)
            
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == self.savedByCollectionView{
            let storyboard = UIStoryboard(name: "Profile", bundle: nil)
            if let destination = storyboard.instantiateViewControllerWithIdentifier("FollowingProfileVC") as? UsersTableViewController{
            destination.userProfile = self.followingUser[indexPath.row].uid
            print(" sending this uid \(destination.userProfile)")
            
            self.navigationController?.pushViewController(destination, animated: true)
        }
        }
    }
    
    @IBAction func onCallButtonPressed(sender: UIButton) {
        
        let alertview = JSSAlertView().show(
            self,
            title: "Call?",
            text: "Are you sure you want to call this number?",
            color: UIColorFromHex(0x00B0FF, alpha: 1),
            iconImage: UIImage(named: "phone-receiver"),
            buttonText: "Yes",
            cancelButtonText: "Cancel" // This tells JSSAlertView to create a two-button alert
        )
        alertview.setTextTheme(.Light)
        alertview.addAction(callFunction)
    }
    
    func callFunction(){
        if let CleanphoneNumber = self.place?.phoneNumber!.stringByReplacingOccurrencesOfString(" ", withString: ""){
            if let phoneCallURL:NSURL = NSURL(string: "tel://\(CleanphoneNumber)") {
                let application:UIApplication = UIApplication.sharedApplication()
                if (application.canOpenURL(phoneCallURL)) {
                    application.openURL(phoneCallURL);
                }
            }
        }else{
            print("No phone number")
        }
    }
    
    
    @IBAction func onWebsiteButtonPressed(sender: UIButton) {
    }
    
    @IBAction func onNavigateButtonPressed(sender: UIButton) {
        performSegueWithIdentifier("RouteSegue", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
//            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
//            let storyboard = UIStoryboard(name: "Profile", bundle: nil)
//            let vc = storyboard.instantiateViewControllerWithIdentifier("FollowingProfileVC") as! UsersTableViewController
//            
//            let indexPath = sender as! NSIndexPath
//            vc.userProfile = self.followingUser[indexPath.row].uid
//            self.navigationController?.pushViewController(vc, animated: true)
        
            
        if segue.identifier == "RouteSegue"{
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
            let destination = segue.destinationViewController as! RouteMapViewController
            destination.place = self.place
        }
    }
    
    @IBAction func onSaveButtonPressed(sender: UIButton) {
        
        if saved {
            showRemoveAlert()
        } else {
            saveFunction()
        }
    }
    
    func showRemoveAlert(){
        let alertview = JSSAlertView().show(
            self,
            title: "Remove?",
            text: "Are you sure you want to unsave this location?",
            color: UIColorFromHex(0xFF1744, alpha: 1),
            iconImage: UIImage(named: "remove-symbol"),
            buttonText: "Yes",
            cancelButtonText: "Cancel" // This tells JSSAlertView to create a two-button alert
        )
        alertview.setTextTheme(.Light)
        alertview.addAction(removeFunction)
    }
    
    func saveFunction(){
        aGMSGeocoder.reverseGeocodeCoordinate(place!.coordinate) { (response, error) in
            
            guard let aGMSAddress = response!.firstResult() else { return }
            
            self.categoryPhotoRef(aGMSAddress.locality!)
            
            let placeDict = ["placeID": self.place!.placeID,
                             "name": self.place!.name,
                             "locality": aGMSAddress.locality!,
                             "longitude": self.place!.coordinate.longitude,
                             "latitude": self.place!.coordinate.latitude,
                             "userUID": User.currentUserUid()!,
                             "created_at": NSDate().timeIntervalSince1970]
            
            // add .child(User.currentUserUid()!)
            let placeRef = DataService.rootRef.child("Place").child(User.currentUserUid()!).child("\(aGMSAddress.locality!)").childByAutoId()
            placeRef.updateChildValues(placeDict as [NSObject : AnyObject])
            
            DataService.usersRef.child(User.currentUserUid()!).child("savedPlace").updateChildValues([placeRef.key: true])
            
            DataService.rootRef.child("usersLocalities").child(User.currentUserUid()!).updateChildValues([aGMSAddress.locality!: true])
            
            self.newSavedPlace = placeRef.key
            self.saved = true
            self.toggleBasedOnSaveState()
        }
        
        let alerView = JSSAlertView().show(self, title: "Saved", text: "This location has been saved!", color: UIColorFromHex(0x2ecc71, alpha: 1), iconImage: UIImage(named: "checked"))
        alerView.setTextTheme(.Light)
        
    }
    
    func removeFunction(){
        
        aGMSGeocoder.reverseGeocodeCoordinate(place!.coordinate) { (response, error) in
            
            guard let aGMSAddress = response!.firstResult() else { return }
            
            if let placeKey = self.aSavedPlace?.placeKey {
                DataService.rootRef.child("Place").child("\(aGMSAddress.locality!)").child(placeKey).removeValue()
                DataService.usersRef.child(User.currentUserUid()!).child("savedPlace").child(placeKey).removeValue()
                self.aSavedPlace?.placeKey = nil
                self.saved = false
                self.toggleBasedOnSaveState()
            } else if let placeKey = self.newSavedPlace {
                DataService.rootRef.child("Place").child("\(aGMSAddress.locality!)").child(placeKey).removeValue()
                DataService.usersRef.child(User.currentUserUid()!).child("savedPlace").child(placeKey).removeValue()
                self.saved = false
                self.toggleBasedOnSaveState()
            }
        }
    }
    
    func categoryPhotoRef(locality: String){
        
        let trimmedLocalityString = locality.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        Alamofire
            .request(.GET, "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(trimmedLocalityString)&key=AIzaSyB7-LGkbhbQJR16q-CvK8_7eBlNNok9Shk")
            .responseJSON { (JSONresponse) in
                switch JSONresponse.result{
                case .Success(let responseValue):
                    let json = JSON(responseValue)
                    
                    if let photoReference = json["results"][0]["photos"][0]["photo_reference"].string{
                        
                        let photoRefDict = ["photoRef": photoReference]
                        
                        DataService.placesRef.child(User.currentUserUid()!).child(locality).child("photoRef").updateChildValues(photoRefDict as [NSObject : AnyObject])
                    }
                    
                case .Failure(let error):
                    print(error.localizedDescription)
                    
                }
        }
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
        
        for (index, photo) in photoMetadata.enumerate() where index < 3{
            GMSPlacesClient.sharedClient().loadPlacePhoto(photo, callback: { (photo, error) in
                if let error = error {
                    // TODO: handle the error.
                    print("Error: \(error.description)")
                } else {
                    self.images.append(photo!)
                    self.collectionView.reloadData()
                }
            })
        }
    }
    
    func getSavedBy(){
        DataService.usersRef.child(User.currentUserUid()!).child("following").observeEventType(.ChildAdded, withBlock: {(followingSnap) in
            DataService.rootRef.child("usersLocalities").child(followingSnap.key).observeEventType(.ChildAdded, withBlock: {(localitiesSnap) in
                DataService.usersRef.child(followingSnap.key).child("savedPlace").observeEventType(.ChildAdded, withBlock: {(userPlaceSnap) in
                    DataService.placesRef.child(followingSnap.key).child(localitiesSnap.key).child(userPlaceSnap.key).observeSingleEventOfType(.Value, withBlock: {(placeValueSnap) in
                        
                        if let SavedPlace = SavedPlace.init(snapshot: placeValueSnap){
                            if SavedPlace.placeID == self.place?.placeID{
                                print("one of the people you follow saved this place")
                                DataService.usersRef.child(followingSnap.key).observeSingleEventOfType(.Value, withBlock: {(userImageSnap) in
                                    if let user = User.init(snapshot: userImageSnap){
                                        self.followingUser.append(user)
                                        self.savedByCollectionView.reloadData()
                                    }
                                })
                            }
                            
                        }
                    })
                })
            })
        })
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y > 64  {
            self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
            self.navigationController?.navigationBar.shadowImage = nil
        } else {
            let progress = scrollView.contentOffset.y / 64
            let image = getNavigationBarImageWith(progress)
            self.navigationController?.navigationBar.setBackgroundImage(image, forBarMetrics: .Default)
            self.navigationController?.navigationBar.shadowImage = image
        }
        scrollView.indicatorStyle = UIScrollViewIndicatorStyle.White
    }
    
}

extension UIImage{
    static func imageWithColor(color: UIColor) -> UIImage{
        let rect = CGRectMake(0, 0, 1, 1);
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        
        UIRectFill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image;
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return round(self * divisor) / divisor
    }
}