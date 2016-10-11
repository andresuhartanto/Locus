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


class FollowingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    @IBOutlet weak var tableView: UITableView!
    var listOfFollowing = [User]()
    var userProfile:String!
    var filteredTableData = [User]()
    var resultSearchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            
            self.tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        
        
        guard let currentUserID = self.userProfile else{
            return
        }
        
        DataService.usersRef.child(currentUserID).child("following").observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.hasChildren(){
                let keyArray = snapshot.value?.allKeys as! [String]
                    for key in keyArray{
                        DataService.usersRef.child(key).observeSingleEventOfType(.Value, withBlock: { userSnapshot in
                            if let users = User(snapshot: userSnapshot){
                                self.listOfFollowing.append(users)
                                
                                for i in self.listOfFollowing{
                                    if i.uid == User.currentUserUid(){
                                        i.isMyself = true
                                    }
                                }
                                self.tableView.reloadData()
                            }
                        })
                    }
                }
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:StaticFollowingCell = tableView.dequeueReusableCellWithIdentifier("FollowingCell") as! StaticFollowingCell
        
        if (self.resultSearchController.active){
            let user = filteredTableData[indexPath.row]
            
            cell.user = user
            cell.nameLabel.text = user.username
            if let userImageUrl = user.profileImage{
                
                let url = NSURL(string: userImageUrl)
                cell.profileImage.sd_setImageWithURL(url)
                cell.profileImage.layer.cornerRadius = (cell.profileImage.frame.size.width)/2
                cell.profileImage.clipsToBounds = true
            }
            
            
            
            DataService.usersRef.child(User.currentUserUid()!).child("following").observeEventType(.Value, withBlock: { snapshot in
                
                if user.isMyself{
                    cell.followingButton.hidden = true
                }else if snapshot.hasChild(user.uid!){
                    
                    cell.followingButton.backgroundColor = UIColor.greenColor()
                    cell.followingButton.setTitle("Following", forState: .Normal)
                    cell.followingButton.layer.cornerRadius = 5
                    cell.followingButton.layer.borderWidth = 1
                    cell.checker = true
                    
                }else{
                    cell.followingButton.backgroundColor = UIColor.clearColor()
                    cell.followingButton.setTitle("Follow", forState: .Normal)
                    cell.followingButton.layer.cornerRadius = 5
                    cell.followingButton.layer.borderWidth = 1
                    cell.checker = false
                }
            })
            
            return cell
        }else{
            let user = listOfFollowing[indexPath.row]
            
            cell.user = user
            cell.nameLabel.text = user.username
            if let userImageUrl = user.profileImage{
                
                let url = NSURL(string: userImageUrl)
                cell.profileImage.sd_setImageWithURL(url)
                cell.profileImage.layer.cornerRadius = (cell.profileImage.frame.size.width)/2
                cell.profileImage.clipsToBounds = true
            }
            
            
            
            DataService.usersRef.child(User.currentUserUid()!).child("following").observeEventType(.Value, withBlock: { snapshot in
                
                if user.isMyself{
                    cell.followingButton.hidden = true
                }else if snapshot.hasChild(user.uid!){
                    
                    cell.followingButton.backgroundColor = UIColor.greenColor()
                    cell.followingButton.setTitle("Following", forState: .Normal)
                    cell.followingButton.layer.cornerRadius = 5
                    cell.followingButton.layer.borderWidth = 1
                    cell.checker = true
                    
                }else{
                    cell.followingButton.backgroundColor = UIColor.clearColor()
                    cell.followingButton.setTitle("Follow", forState: .Normal)
                    cell.followingButton.layer.cornerRadius = 5
                    cell.followingButton.layer.borderWidth = 1
                    cell.checker = false
                }
            })
            
            return cell
        }
        
        
        
    }
    
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        filteredTableData.removeAll(keepCapacity: false)
        
        let array = listOfFollowing.filter(){
            ($0.username!.lowercaseString).rangeOfString(searchController.searchBar.text!.lowercaseString) != nil
        }
        filteredTableData = array
        
        self.tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (self.resultSearchController.active) {
            return self.filteredTableData.count
        }
        else {
            return self.listOfFollowing.count
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let user = listOfFollowing[indexPath.row]
        
        self.userProfile = user.uid
        self.performSegueWithIdentifier("UserSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "UserSegue"{
            let nextScene = segue.destinationViewController as! UsersTableViewController
            nextScene.userProfile = self.userProfile
        }
    }
}






//
//        DataService.usersRef.child("following").observeEventType(.Value, withBlock: { usersSnapshot in
//            for userSnapshot in usersSnapshot.children.allObjects {
//                if let user = User(snapshot: userSnapshot as! FIRDataSnapshot){
//                    self.listOfFollowing.append(user)
//
//                    for (index,i) in self.listOfFollowing.enumerate(){
//                        if i.uid == User.currentUserUid(){
//                            self.listOfFollowing.removeAtIndex(index)
//                        }
//                    }
//
//                    self.tableView.reloadData()
//                }
//            }
//        })
