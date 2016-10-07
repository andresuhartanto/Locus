//
//  LocationViewController.swift
//  Locus
//
//  Created by Bryan Lee on 05/10/2016.
//  Copyright © 2016 EndeJeje. All rights reserved.
//

import UIKit

class LocationViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var imageDetails: UICollectionView!
    @IBOutlet weak var imageView: UIImageView!

    var listOfPlaces = [Place]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageDetails.delegate = self
        imageDetails.dataSource = self
        
//        self.imageView.image = self.image

    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenWidth = self.view.frame.size.width
        let itemWidth = screenWidth / 2
        return CGSizeMake(itemWidth, itemWidth)
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 30
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = imageDetails.dequeueReusableCellWithReuseIdentifier("DetailCell", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.whiteColor()
        return cell
    }
//    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        let user = listOfPlaces[indexPath.row]
//        self.hotel = user.uid
//        self.performSegueWithIdentifier("UserSegue", sender: self)
//    }

}
