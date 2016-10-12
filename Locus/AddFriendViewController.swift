//
//  AddFriendViewController.swift
//  Locus
//
//  Created by Andre Suhartanto on 10/12/16.
//  Copyright © 2016 EndeJeje. All rights reserved.
//

import UIKit
import SDWebImage
import FirebaseDatabase

class AddFriendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchControllerDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    var listOfUsers = [User]()
    var userProfile: String?
    var filteredTableData = [User]()
    var resultSearchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllUsers()
        definesPresentationContext = true
        
        self.resultSearchController = {
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.barTintColor = UIColor.whiteColor()
            controller.searchBar.tintColor = UIColor.whiteColor()
            controller.searchBar.sizeToFit()
            controller.delegate = self
            controller.searchBar.backgroundImage = UIImage()
            self.tableView.tableHeaderView = controller.searchBar
            
            return controller
        }()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let image = getNavigationBarImageWith(1)
        self.navigationController?.navigationBar.setBackgroundImage(image, forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = image
    }
    
    func willPresentSearchController(searchController: UISearchController) {
        searchController.searchBar.barTintColor = UIColor.locusBlueColor()
    }
    
    func willDismissSearchController(searchController: UISearchController) {
        searchController.searchBar.barTintColor = UIColor.whiteColor()
    }
    
    
    
    func getAllUsers(){
        DataService.usersRef.observeEventType(.ChildAdded, withBlock: {(userSnap) in
            DataService.usersRef.child(userSnap.key).observeSingleEventOfType(.Value , withBlock: {(aUserSnap) in
                if let users = User(snapshot: aUserSnap){
                    self.listOfUsers.append(users)
                    
                    for (index, currentUser) in self.listOfUsers.enumerate(){
                        if currentUser.uid == User.currentUserUid(){
                            currentUser.isMyself = true
                            self.listOfUsers.removeAtIndex(index)
                        }
                    }
                    self.tableView.reloadData()
                }
            })
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.resultSearchController.active) {
            return self.filteredTableData.count
        }
        else {
            return self.listOfUsers.count
        }
        
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        filteredTableData.removeAll(keepCapacity: false)
        
        let array = listOfUsers.filter(){
            ($0.username!.lowercaseString).rangeOfString(searchController.searchBar.text!.lowercaseString) != nil
        }
        filteredTableData = array
        
        self.tableView.reloadData()
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AddFriendCell") as! AddFriendTableViewCell
        if (self.resultSearchController.active){
            let user = filteredTableData[indexPath.row]
            
            cell.user = user
            cell.nameLabel.text = user.username
            if let userImageURL = user.profileImage{
                let url = NSURL(string: userImageURL)
                cell.profileImage.sd_setImageWithURL(url)
                cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width / 2
                cell.profileImage.clipsToBounds = true
            }
            DataService.usersRef.child(User.currentUserUid()!).child("following").observeEventType(.Value , withBlock: {(snapshot) in
                
                
                if snapshot.hasChild(user.uid!){
                    cell.followButton.backgroundColor = UIColor.locusBlueColor()
                    cell.followButton.setTitle("Following", forState: .Normal)
                    cell.followButton.layer.cornerRadius = 5
                    cell.followButton.layer.borderWidth = 1
                    cell.checker = true
                }else{
                    cell.followButton.backgroundColor = UIColor.clearColor()
                    cell.followButton.setTitle("Follow", forState: .Normal)
                    cell.followButton.layer.cornerRadius = 5
                    cell.followButton.layer.borderWidth = 1
                    cell.checker = false
                    
                }
            })
            return cell
            
        }else{
            let user = listOfUsers[indexPath.row]
            
            cell.user = user
            cell.nameLabel.text = user.username
            if let userImageURL = user.profileImage{
                let url = NSURL(string: userImageURL)
                cell.profileImage.sd_setImageWithURL(url)
                cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width / 2
                cell.profileImage.clipsToBounds = true
            }
            DataService.usersRef.child(User.currentUserUid()!).child("following").observeEventType(.Value , withBlock: {(snapshot) in
                if user.isMyself{
                    cell.followButton.hidden = true
                } else if snapshot.hasChild(user.uid!){
                    cell.followButton.backgroundColor = UIColor.locusBlueColor()
                    cell.followButton.setTitle("Following", forState: .Normal)
                    cell.followButton.layer.cornerRadius = 5
                    cell.followButton.layer.borderWidth = 1
                    cell.checker = true
                }else{
                    cell.followButton.backgroundColor = UIColor.clearColor()
                    cell.followButton.setTitle("Follow", forState: .Normal)
                    cell.followButton.layer.cornerRadius = 5
                    cell.followButton.layer.borderWidth = 1
                    cell.checker = false
                }
                
            })
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (self.resultSearchController.active){
            let user = filteredTableData[indexPath.row]
            let storyboard = UIStoryboard(name: "Profile", bundle: nil)
            if let destination = storyboard.instantiateViewControllerWithIdentifier("FollowingProfileVC") as? UsersTableViewController{
                destination.userProfile = user.uid
                self.navigationController?.pushViewController(destination, animated: true)
            }
            
            }else{
                let user = listOfUsers[indexPath.row]
                let storyboard = UIStoryboard(name: "Profile", bundle: nil)
                if let destination = storyboard.instantiateViewControllerWithIdentifier("FollowingProfileVC") as? UsersTableViewController{
                    destination.userProfile = user.uid
                    self.navigationController?.pushViewController(destination, animated: true)
                    
                }
                
            }
    }
    
}
