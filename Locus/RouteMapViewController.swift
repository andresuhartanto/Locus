//
//  RouteMapViewController.swift
//  Locus
//
//  Created by Andre Suhartanto on 10/3/16.
//  Copyright © 2016 EndeJeje. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import SwiftyJSON

class RouteMapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: GMSMapView!
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var place: GMSPlace?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        mapView.delegate = self
        
        self.navigationItem.title = "Route"
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let image = getNavigationBarImageWith(1)
        self.navigationController?.navigationBar.setBackgroundImage(image, forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = image
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 16, bearing: 0, viewingAngle: 0.0)
            mapView.myLocationEnabled = true
            
            locationManager.stopUpdatingLocation()
            
            routing(location)
        }
    }
    
    func routing(origin: CLLocation){
        
        guard let lat = self.place?.coordinate.latitude, let long = self.place?.coordinate.longitude else { return }
        
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin.coordinate.latitude),\(origin.coordinate.longitude)&destination=\(lat),\(long)&key=AIzaSyB7-LGkbhbQJR16q-CvK8_7eBlNNok9Shk"
        
        let marker = GMSMarker(position: self.place!.coordinate)
        marker.appearAnimation = kGMSMarkerAnimationPop
        
        if marker == 0{
            marker.map = self.mapView
        }else if marker != 0{
            self.mapView.clear()
            marker.map = self.mapView
        }

        
        Alamofire
            .request(.GET, urlString)
            .responseJSON { (response) in
                switch response.result{
                case .Success(let responceValue):
                    let json = JSON(responceValue)
                    
                    if let path = GMSPath.init(fromEncodedPath: json["routes"][0]["overview_polyline"]["points"].string!) {
                        
                        let bounds = GMSCoordinateBounds(path: path)
                        let update = GMSCameraUpdate.fitBounds(bounds)
                        self.mapView.moveCamera(update)
                        
                        let singleLine = GMSPolyline.init(path: path)
                        singleLine.strokeWidth = 5
                        singleLine.strokeColor = UIColor.blueColor()
                        singleLine.map = self.mapView
                    }
                    
                case .Failure(let error):
                    print(error.localizedDescription)
                }
        }
    }

}
