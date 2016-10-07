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
    var listOfUser = [Place]()
    var listOfLocation = [Location]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        DataService.placesRef.observeEventType(.ChildAdded, withBlock: { placeSnapshot in
            DataService.placesRef.child(placeSnapshot.key).observeSingleEventOfType(.ChildAdded, withBlock: {(snapshot) in
                
                if let place = Place(snapshot:snapshot){
                    DataService.usersRef.child(place.userUID!).observeSingleEventOfType(.Value, withBlock: {userSnapshot in
                        if let user = User(snapshot:userSnapshot){
                            place.userUID = user.userUID
                            self.listOfUser.append(place)
                            let location = Location.init()
                            location.name = place.name
                            location.placeID = place.placeID
                            
                            self.loadFirstPhotoForPlace(location)
                            self.tableView.reloadData()
                        }
                    })
                }
            })
        })

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
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfLocation.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: StaticProfileCell = tableView.dequeueReusableCellWithIdentifier("ListSegue") as! StaticProfileCell
        let location = listOfLocation[indexPath.row]
        
        cell.placeImageView.image = location.image
        cell.placeImageView.layer.shadowOpacity = 0.7
        cell.placeImageView.layer.shadowRadius = 10.0
        cell.placesNameLabel.text = location.name
        
        return cell
    }

}
