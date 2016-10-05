//
//  RouteMapViewController.swift
//  Locus
//
//  Created by Andre Suhartanto on 10/3/16.
//  Copyright © 2016 EndeJeje. All rights reserved.
//

import UIKit
import GoogleMaps

class RouteMapViewController: UIViewController, GMSMapViewDelegate {

    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self

    }

}
