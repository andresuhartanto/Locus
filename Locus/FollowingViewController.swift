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


class FollowingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var listOfFollowing = [User]()
    var userProfile:String!
//    var filtered:String = []
    var searchActive: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfFollowing.count
    }
    
   func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        let cell:StaticFollowingCell = tableView.dequeueReusableCellWithIdentifier("FollowingCell") as! StaticFollowingCell

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
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false
    }
//    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
//        
//        if self.listOfFollowing.isEmpty {
//            
//            // set searching false
//            self.searchActive = false
//            
//            // reload table view
//            self.tableView.reloadData()
//            
//        }else{
//            
//            // set searghing true
//            self.searchActive = true
//            
//            // empty searching array
//            self.filtered.removeAll(keepCapacity: false)
//            
//            // find matching item and add it to the searcing array
//            for i in 0..<self.listOfFollowing.count {
//                
//                let listItem = self.listOfFollowing[i]
//                    self.filtered.append(listItem)
//                }
//            }
//            
//            self.tableView.reloadData()
//        }

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
