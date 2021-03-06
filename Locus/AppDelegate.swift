//
//  AppDelegate.swift
//  Locus
//
//  Created by Andre Suhartanto on 9/26/16.
//  Copyright © 2016 EndeJeje. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        FIRApp.configure()
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        GMSServices.provideAPIKey("AIzaSyB7-LGkbhbQJR16q-CvK8_7eBlNNok9Shk")
        GMSPlacesClient.provideAPIKey("AIzaSyB7-LGkbhbQJR16q-CvK8_7eBlNNok9Shk")
        
        // if this key exist in userDefault
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey("userUID") as? String{
            
            // load storyboard
            let storyBoard = UIStoryboard(name: "MapView", bundle: NSBundle.mainBundle())
            // load view controller with the storyboardID of HomeTabBarController
            let viewController = storyBoard.instantiateViewControllerWithIdentifier("MapViewController")
            
            self.window?.rootViewController = viewController
            
        }
        
        autocompleteStyling()
        
        return true
    }
    
    func autocompleteStyling(){
        // Define some colors. UIColor.init(red: 37/255, green: 183/255, blue: 211/255, alpha: 1)
        let scooter = UIColor.init(red: 0/255, green: 176/255, blue: 255/255, alpha: 1)
        let lightGray = UIColor.lightGrayColor()
        // Navigation bar background.
        UINavigationBar.appearance().barTintColor = scooter
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        // Color of typed text in the search bar.
        let searchBarTextAttributes = [NSForegroundColorAttributeName: lightGray, NSFontAttributeName: UIFont.systemFontOfSize(UIFont.systemFontSize())]
        UITextField.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).defaultTextAttributes = searchBarTextAttributes
        
        // Color of the placeholder text in the search bar prior to text entry.
        let placeholderAttributes = [NSForegroundColorAttributeName: lightGray, NSFontAttributeName: UIFont.systemFontOfSize(UIFont.systemFontSize())]
        // Color of the default search text.
        // NOTE: In a production scenario, "Search" would be a localized string.
        let attributedPlaceholder = NSAttributedString(string: "Search", attributes: placeholderAttributes)
        UITextField.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).attributedPlaceholder = attributedPlaceholder
        // Color of the in-progress spinner.
        UIActivityIndicatorView.appearance().color = lightGray
        // To style the two image icons in the search bar (the magnifying glass
        // icon and the 'clear text' icon), replace them with different images.
        //        UISearchBar.appearance().setImage(UIImage(named: "custom_clear_x_high")!, forSearchBarIcon: .Clear , state: .Highlighted)
        //        UISearchBar.appearance().setImage(UIImage(named: "custom_clear_x")!, forSearchBarIcon: .Clear, state: .Normal)
        //        UISearchBar.appearance().setImage(UIImage(named: "custom_search")!, forSearchBarIcon: .Search, state: .Normal)
        // Color of selected table cells.
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.lightGrayColor()
        UITableViewCell.appearanceWhenContainedInInstancesOfClasses([GMSAutocompleteViewController.self]).selectedBackgroundView = selectedBackgroundView
        
        UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).tintColor = UIColor.whiteColor()
    }
    
    
    func application(application: UIApplication, openURL url: NSURL, options: [String: AnyObject]) -> Bool {
        
        if (FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String, annotation: options[UIApplicationOpenURLOptionsAnnotationKey])){
            
            return true
        }
        
        return false
        
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

