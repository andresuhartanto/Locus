//
//  ViewController.swift
//  Locus
//
//  Created by Andre Suhartanto on 9/26/16.
//  Copyright © 2016 EndeJeje. All rights reserved.
//

import UIKit
import FirebaseAuth


class SignUpViewController: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.delegate = self

    }
    
    override func unwindForSegue(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        
    }

    @IBAction func onSignUpButtonPressed(sender: UIButton) {
        guard
            let username = usernameTextField.text,
            let email = emailTextField.text,
            let password = passwordTextField.text else{
                return
        }
        
        FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: {(user, error) in
            if let user = user{
                
                // stores into user defaults under key userUID, the user's
                NSUserDefaults.standardUserDefaults().setObject((user.uid), forKey: "userUID")
                
                self.performSegueWithIdentifier("HomeSegue", sender: nil)
                
                let currentUserRef = DataService.usersRef.child(user.uid)
                let userDict = ["email": email, "username": username]
                currentUserRef.setValue(userDict)
                
                
            }else{
                let alert = UIAlertController(title: "Sign Up Failed", message: error?.localizedDescription, preferredStyle: .Alert)
                
                let dismissAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
                
                alert.addAction(dismissAction)
                
                self.presentViewController(alert, animated:true, completion: nil)
                
            }
        })
        
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if let error = error {
            print(error.localizedDescription)
            return
        }
        let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
        
        FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
            if let user = user{
                
                NSUserDefaults.standardUserDefaults().setObject(user.uid, forKey: "userUID")
                
                let currentUserRef = DataService.usersRef.child(user.uid)
                var userDict: Dictionary<String, String> = [:]
                
                if user.providerData[0].displayName != nil {
                    userDict["username"] = user.providerData[0].displayName
                }
                if user.providerData[0].email != nil {
                    userDict["email"] = user.providerData[0].email
                }
                currentUserRef.setValue(userDict)
                
                let appDelegateTemp = UIApplication.sharedApplication().delegate!
                
                let storyBoard = UIStoryboard(name: "MapView", bundle: NSBundle.mainBundle())
                // load view controller with the storyboardID of HomeTabBarController
                let tabBarController = storyBoard.instantiateViewControllerWithIdentifier("MapViewController")
                
                appDelegateTemp.window?!.rootViewController = tabBarController
            }
        }
        
    }
    
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }


}

