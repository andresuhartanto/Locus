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

class PlaceDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NVActivityIndicatorViewable {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addresLabel: UILabel!
    @IBOutlet weak var BusinesshourLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    var place: GMSPlace?
    var images = [UIImage]()
    var defaultNavigationBar : UINavigationBar?
    var saved: Bool = false
    let aGMSGeocoder = GMSGeocoder()
    var aSavedPlace: SavedPlace?
    
    var newSavedPlace: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = place?.name
        addresLabel.text = place?.formattedAddress
        BusinesshourLabel.text = "Open"
        phoneNumberLabel.text = place?.phoneNumber
        
        let website = place?.website
        if website != nil{
            websiteLabel.text = place?.website?.absoluteString
        }else{
            websiteLabel.text = "Not Available"
        }
        
        loadFirstPhotoForPlace(place!.placeID)
        
        defaultNavigationBar = self.navigationController?.navigationBar
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        title = place?.name
        
        let image = getNavigationBarImageWith(0.0)
        self.navigationController?.navigationBar.setBackgroundImage(image, forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = image
        
        toggleBasedOnSaveState()
        
    }
    
    func toggleBasedOnSaveState(){
        if saved {
            saveButton.setTitle("Unsave", forState: .Normal)
        } else if saved == false {
            saveButton.setTitle("Save", forState: .Normal)
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! ImageCollectionViewCell
        cell.imageView.image = images[indexPath.row]
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = self.view.frame.size.width
        let height = collectionView.frame.size.height
        return CGSizeMake(width, height)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    @IBAction func onCallButtonPressed(sender: UIButton) {
    }
    @IBAction func onShareButtonPressed(sender: UIButton) {
    }
    @IBAction func onNavigateButtonPressed(sender: UIButton) {
        performSegueWithIdentifier("RouteSegue", sender: nil)
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
            
            let placeDict = ["placeID": self.place!.placeID,
                             "name": self.place!.name,
                             "locality": aGMSAddress.locality!,
                             "longitude": self.place!.coordinate.longitude,
                             "latitude": self.place!.coordinate.latitude,
                             "userUID": User.currentUserUid()!]
            let placeRef = DataService.rootRef.child("Place").childByAutoId()
            placeRef.updateChildValues(placeDict as [NSObject : AnyObject])
            
            DataService.usersRef.child(User.currentUserUid()!).child("savedPlace").updateChildValues([placeRef.key: true])
            self.newSavedPlace = placeRef.key
            self.saved = true
            self.toggleBasedOnSaveState()
        }
        
        let alerView = JSSAlertView().show(self, title: "Saved", text: "This location has been saved!", color: UIColorFromHex(0x2ecc71, alpha: 1), iconImage: UIImage(named: "checked"))
        alerView.setTextTheme(.Light)
        
    }
    
    func removeFunction(){
        if let placeKey = self.aSavedPlace?.placeKey {
            DataService.rootRef.child("Place").child(placeKey).removeValue()
            DataService.usersRef.child(User.currentUserUid()!).child("savedPlace").child(placeKey).removeValue()
            self.aSavedPlace?.placeKey = nil
            self.saved = false
            self.toggleBasedOnSaveState()
        } else if let placeKey = self.newSavedPlace {
            DataService.rootRef.child("Place").child(placeKey).removeValue()
            DataService.usersRef.child(User.currentUserUid()!).child("savedPlace").child(placeKey).removeValue()
            self.saved = false
            self.toggleBasedOnSaveState()
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