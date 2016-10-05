//
//  FollowerViewController.swift
//  Locus
//
//  Created by Bryan Lee on 03/10/2016.
//  Copyright © 2016 EndeJeje. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SDWebImage


class FollowerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var listOfFollower = [User]()
    var userProfile: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        guard let currentUserID = self.userProfile else{
            return
        }
        
        DataService.usersRef.child(currentUserID).child("follower").observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.hasChildren(){
                let keyArray = snapshot.value?.allKeys as! [String]
                for key in keyArray{
                    DataService.usersRef.child(key).observeSingleEventOfType(.Value, withBlock: { userSnapshot in
                        if let users = User(snapshot: userSnapshot){
                            self.listOfFollower.append(users)
                            
                            for i in self.listOfFollower{
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
        return listOfFollower.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:StaticFollowerCell = tableView.dequeueReusableCellWithIdentifier("FollowerCell") as! StaticFollowerCell
        let user = listOfFollower[indexPath.row]
        
        cell.nameLabel.text = user.username
        cell.user = user
        if let userImageUrl = user.profileImage{
            
            let url = NSURL(string: userImageUrl)
            cell.followerImage.sd_setImageWithURL(url)
            cell.followerImage.layer.cornerRadius = (cell.followerImage.frame.size.width)/2
            cell.followerImage.clipsToBounds = true

        }
        DataService.usersRef.child(User.currentUserUid()!).child("following").observeEventType(.Value, withBlock: { snapshot in
            
            if user.isMyself{
                cell.followerButton.hidden = true
                
            }else if snapshot.hasChild(user.uid!){
                cell.followerButton.backgroundColor = UIColor.greenColor()
                cell.followerButton.setTitle("Following", forState: .Normal)
                cell.followerButton.layer.cornerRadius = 5
                cell.followerButton.layer.borderWidth = 1
                cell.checker = true
                
            }else{
                cell.followerButton.backgroundColor = UIColor.clearColor()
                cell.followerButton.setTitle("Follow", forState: .Normal)
                cell.followerButton.layer.cornerRadius = 5
                cell.followerButton.layer.borderWidth = 1
                cell.checker = false
            }
        })
        
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let user = listOfFollower[indexPath.row]
        
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
