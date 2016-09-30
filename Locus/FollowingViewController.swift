//
//  FollowingViewController.swift
//  Locus
//
//  Created by Bryan Lee on 30/09/2016.
//  Copyright © 2016 EndeJeje. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SDWebImage


class FollowingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var listOfFollowing = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        DataService.usersRef.observeEventType(.Value, withBlock: { usersSnapshot in
            for userSnapshot in usersSnapshot.children.allObjects {
                if let user = User(snapshot: userSnapshot as! FIRDataSnapshot){
                    self.listOfFollowing.append(user)
                    
                    for (index,i) in self.listOfFollowing.enumerate(){
                        if i.uid == User.currentUserUid(){
                            self.listOfFollowing.removeAtIndex(index)
                        }
                    }
                    
                    self.tableView.reloadData()
                    print("added")
                }
            }
            
        })
        
        
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfFollowing.count
    }
    
   func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:StaticFollowingCell = tableView.dequeueReusableCellWithIdentifier("FollowingCell") as! StaticFollowingCell
        let user = listOfFollowing[indexPath.row]
        
        cell.nameLabel.text = user.username
        if let userImageUrl = user.profileImage{
            
            let url = NSURL(string: userImageUrl)
            cell.profileImage.sd_setImageWithURL(url)
            cell.profileImage.layer.cornerRadius = (cell.profileImage.frame.size.width)/2
            cell.profileImage.clipsToBounds = true
        }
        
        return cell
    }
}
