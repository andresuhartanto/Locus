//
//  ListOfPlacesViewController.swift
//  Locus
//
//  Created by Bryan Lee on 06/10/2016.
//  Copyright © 2016 EndeJeje. All rights reserved.
//

import UIKit
import GooglePlaces

class ListOfPlacesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    
    var titleName: String!
    var userProfile: String!
    var location = [Place]()
    var newLocation = [Place]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        self.title = self.titleName
        
        
        for i in self.location{
            if self.newLocation.count != 0{
                if (self.newLocation.contains { $0.uid != i.uid }){
                    self.newLocation.append(i)
                }
            }else{
                self.newLocation.append(i)
            }
        }
        
        
        for i in self.newLocation{
            
            loadFirstPhotoForPlace(i)
            
        }
    }
    
    
    
    func loadFirstPhotoForPlace(location: Place) {
        
        GMSPlacesClient.sharedClient().lookUpPhotosForPlaceID(location.placeID!) { (photos, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.description)")
            } else {
                if let photos = photos?.results {
                    self.loadImageForMetadata(photos,location: location)
                }
            }
        }
    }
    
    func loadImageForMetadata(photoMetadata: [GMSPlacePhotoMetadata], location: Place) {
        
        for (index, photo) in photoMetadata.enumerate() where index < 1{
            GMSPlacesClient.sharedClient().loadPlacePhoto(photo, callback: { (photo, error) in
                if let error = error {
                    // TODO: handle the error.
                    print("Error: \(error.description)")
                } else {
                    location.image = photo
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newLocation.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: StaticProfileCell = tableView.dequeueReusableCellWithIdentifier("ListSegue") as! StaticProfileCell
        let location = self.newLocation[indexPath.row]
        
        cell.placeImageView.image = location.image
        cell.placesNameLabel.text = location.name
        cell.placesNameLabel.textColor = UIColor.whiteColor()
        
        let date = NSDate(timeIntervalSince1970: location.dateCreated!)
        
        let dayTimePeriodFormatter = NSDateFormatter()
        dayTimePeriodFormatter.dateFormat = "dd MMM YYYY"
        
        let dateString = dayTimePeriodFormatter.stringFromDate(date)
        
        cell.dateCreatedLabel.text = dateString
        cell.dateCreatedLabel.textColor = UIColor.whiteColor()

        
        return cell
    }

}
