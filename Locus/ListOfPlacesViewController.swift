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
    var listOfLocation = [Location]()
    var locality: String!
    var placeID: String!
    
    var place: GMSPlace?
    
    var placesClient: GMSPlacesClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        self.title = self.titleName
        
        placesClient = GMSPlacesClient.sharedClient()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        
        guard let currentUserUID = self.userProfile else { return }
        
        DataService.placesRef.child(currentUserUID).observeEventType(.ChildAdded, withBlock: {snapshot in
            DataService.placesRef.child(currentUserUID).child(snapshot.key).observeEventType(.ChildAdded, withBlock: {snapshot2 in
                if let place = Place(snapshot: snapshot2){
                    let location = Location.init()
                    location.placeID = place.placeID
                    location.dateCreated = place.dateCreated
                    location.name = place.name
                    location.cityName = place.locality
                    self.loadFirstPhotoForPlace(location)
                    
                }
            })
        })
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let image = getNavigationBarImageWith(1)
        self.navigationController?.navigationBar.setBackgroundImage(image, forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = image
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    func loadFirstPhotoForPlace(location: Location) {
        
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
    
    func loadImageForMetadata(photoMetadata: [GMSPlacePhotoMetadata], location: Location) {
        
        for (index, photo) in photoMetadata.enumerate() where index < 1{
            GMSPlacesClient.sharedClient().loadPlacePhoto(photo, callback: { (photo, error) in
                if let error = error {
                    // TODO: handle the error.
                    print("Error: \(error.description)")
                } else {
                    location.image = photo
                    self.listOfLocation.append(location)
                    
                    for (index,i) in self.listOfLocation.enumerate(){
                        if i.cityName != self.locality{
                            self.listOfLocation.removeAtIndex(index)
                        }
                    }
                    
                    self.tableView.reloadData()
                }
            })
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PlaceDetailSegue"{
            let nextScene = segue.destinationViewController as! PlaceDetailViewController
            nextScene.place = self.place
            nextScene.saved = true
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfLocation.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: StaticProfileCell = tableView.dequeueReusableCellWithIdentifier("ListSegue") as! StaticProfileCell
        let location = listOfLocation[indexPath.row]
        
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
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let location = listOfLocation[indexPath.row]
        
        placesClient?.lookUpPlaceID(location.placeID!, callback: { (place, error) in
            self.place = place
            self.performSegueWithIdentifier("PlaceDetailSegue", sender: self)

        })
        
        
        
    }

}
