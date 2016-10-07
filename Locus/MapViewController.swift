//
//  MapViewController.swift
//  Locus
//
//  Created by Andre Suhartanto on 9/26/16.
//  Copyright © 2016 EndeJeje. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    
    let locationManager = CLLocationManager()
    
    let infoMarker = GMSMarker()
    var placesClient: GMSPlacesClient?
    
    var place: GMSPlace?
    
    var savedPlace = [SavedPlace]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        mapView.delegate = self
        
        
        placesClient = GMSPlacesClient.sharedClient()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let image = getNavigationBarImageWith(1)
        self.navigationController?.navigationBar.setBackgroundImage(image, forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = image
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        searchView()
        self.savedPlace.removeAll()
        mapView.clear()
        getSavedPlace()
    }
    
    
    func searchView(){
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        self.navigationItem.titleView = searchController?.searchBar
        
        self.definesPresentationContext = true
        
        searchController?.hidesNavigationBarDuringPresentation = false
        searchController?.modalPresentationStyle = UIModalPresentationStyle.Popover
    }
    
    func mapView(mapView: GMSMapView, didTapPOIWithPlaceID placeID: String,
                 name: String, location: CLLocationCoordinate2D) {
        infoMarker.snippet = placeID
        infoMarker.position = location
        infoMarker.title = name
        infoMarker.opacity = 0;
        infoMarker.infoWindowAnchor.y = 1
        infoMarker.map = mapView
        
        let camera = GMSCameraPosition(target: location, zoom: 16, bearing: 0, viewingAngle: 0.0)
        mapView.animateToCameraPosition(camera)
        mapView.selectedMarker = infoMarker
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 16, bearing: 0, viewingAngle: 0.0)
            mapView.myLocationEnabled = true
            
            locationManager.stopUpdatingLocation()
        }
    }
    
    func mapView(mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let markerView = NSBundle.mainBundle().loadNibNamed("MarkerInfoView", owner: self, options: nil).first as! MarkerInforView
        
        markerView.nameLabel.text = marker.title
        markerView.layer.cornerRadius = 10
        
        return markerView
        
    }
    
    func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) {
        print("Info Marker tapped")
        let placeId = marker.snippet!
        
        placesClient?.lookUpPlaceID(placeId, callback: { (place, error) in
            self.place = place
            self.performSegueWithIdentifier("DetailSegue", sender: nil)
        })
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "DetailSegue"{
            let destination = segue.destinationViewController as! PlaceDetailViewController
            destination.place = self.place
            let placeId: String = (self.place?.placeID)!
            // check if any of the SavedPlace have this placeID
            for sPlace in self.savedPlace {
                if sPlace.placeID! == placeId {
                    destination.saved = true
                    destination.aSavedPlace = sPlace
                }
            }
        }
    }
    
    func getSavedPlace(){
        DataService.usersRef.child(User.currentUserUid()!).child("savedPlace").observeEventType(.ChildAdded , withBlock: { (snapshot) in
            DataService.rootRef.child("Place").observeEventType(.ChildAdded , withBlock: {(localitySnap) in
                DataService.rootRef.child("Place").child(localitySnap.key).child(snapshot.key).observeSingleEventOfType(.Value , withBlock: {(snap) in
                    if let savedPlace = SavedPlace.init(snapshot: snap){
                        self.savedPlace.append(savedPlace)
                    }
                    
                    for place in self.savedPlace{
                        self.populateMapview(place)
                    }
                })
            })
        })
    }
    
    func populateMapview(savedPlace: SavedPlace){
        let latitude = savedPlace.latitude
        let longitude = savedPlace.longitude
        let coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
        let marker = GMSMarker(position: coordinate)
        //        let circularImage = UIImageView()
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.icon = UIImage(named: "placeholder-4")
        marker.snippet = savedPlace.placeID
        marker.title = savedPlace.name
        
        marker.map = mapView
    }
}


extension UIViewController {
    
    func getNavigationBarImageWith(alpha: CGFloat) -> UIImage{
        if let color = self.navigationController?.navigationBar.barTintColor?.colorWithAlphaComponent(alpha){
            let image = UIImage.imageWithColor(color)
            return image
        }else{
            return UIImage()
        }
    }
}



// Handle the user's selection.
extension MapViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWithPlace place: GMSPlace) {
        searchController?.active = false
        // Do something with the selected place.
        
        mapView.camera = GMSCameraPosition(target: place.coordinate, zoom: 16, bearing: 0, viewingAngle: 0.0)
        let position = place.coordinate
        let marker = GMSMarker(position: position)
        marker.title = place.name
        
        marker.snippet = place.placeID
        
        marker.appearAnimation = kGMSMarkerAnimationPop
        if marker == 0{
            marker.map = mapView
        }else if marker != 0{
            mapView.clear()
            getSavedPlace()
            marker.map = mapView
        }
    }
    
    func resultsController(resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: NSError){
        // TODO: handle the error.
        print("Error: ", error.description)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictionsForResultsController(resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictionsForResultsController(resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
}
