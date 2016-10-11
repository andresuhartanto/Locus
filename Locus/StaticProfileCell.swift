//
//  StaticProfileCell.swift
//  Locus
//
//  Created by Bryan Lee on 05/10/2016.
//  Copyright © 2016 EndeJeje. All rights reserved.
//

import UIKit

class StaticProfileCell: UITableViewCell {
    
    //Profile Table
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var cityNameLabel: UILabel!
    
    // List Of Places
    @IBOutlet weak var placeImageView: UIImageView!

    @IBOutlet weak var placesNameLabel: UILabel!
    
    @IBOutlet weak var dateCreatedLabel: UILabel!
    
    // User Table
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var userLabel: UILabel!
    
}
