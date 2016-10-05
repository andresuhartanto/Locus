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
    var image: UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageDetails.delegate = self
        imageDetails.dataSource = self
        
        self.imageView.image = self.image

    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = imageDetails.dequeueReusableCellWithReuseIdentifier("DetailCell", forIndexPath: indexPath)
        return cell
    }
}
