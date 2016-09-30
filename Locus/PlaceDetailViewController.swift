//
//  PlaceDetailViewController.swift
//  Locus
//
//  Created by Andre Suhartanto on 9/28/16.
//  Copyright © 2016 EndeJeje. All rights reserved.
//

import UIKit
import GooglePlaces

class PlaceDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addresLabel: UILabel!
    @IBOutlet weak var BusinesshourLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    
    var place: GMSPlace?
    var images = [UIImage]()
    var defaultNavigationBar : UINavigationBar?
    
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
    @IBAction func onSaveButtonPressed(sender: UIButton) {
    }
    @IBAction func onShareButtonPressed(sender: UIButton) {
    }
    @IBAction func onNavigateButtonPressed(sender: UIButton) {
    }
    
    func loadFirstPhotoForPlace(placeID: String) {
        GMSPlacesClient.sharedClient().lookUpPhotosForPlaceID(placeID) { (photos, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.description)")
            } else {
                if let firstPhoto = photos?.results {
                    self.loadImageForMetadata(firstPhoto)
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