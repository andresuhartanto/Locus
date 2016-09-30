//
//  LoginViewController.swift
//  Locus
//
//  Created by Andre Suhartanto on 9/26/16.
//  Copyright © 2016 EndeJeje. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var forgotDetailButton: UIButton!
    
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var signupButton: UIButton!
    
    @IBOutlet weak var facebookSignin: UIButton!
    @IBOutlet weak var facebookSignup: UIButton!
    
    var loginManager: FBSDKLoginManager?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loginManager = FBSDKLoginManager()
        
        customEmailTextField()
        customPasswordTextField()
        customNameTextField()
        
        segmentedControl.removeBorders()
        segmentedControl.setFontSize(20)
        
        signinButton.hidden = false
        facebookSignin.hidden = false
        forgotDetailButton.hidden = false
        nameTextField.hidden = true
        signupButton.hidden = true
        facebookSignup.hidden = true
        
    }
    
    @IBAction func onSignUpButtonPressed(sender: UIButton) {
        guard
            let name = nameTextField.text,
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
                let userDict = ["email": email, "username": name]
                currentUserRef.setValue(userDict)
                
                
            }else{
                let alert = UIAlertController(title: "Sign Up Failed", message: error?.localizedDescription, preferredStyle: .Alert)
                
                let dismissAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
                
                alert.addAction(dismissAction)
                
                self.presentViewController(alert, animated:true, completion: nil)
                
            }
        })
    }
    
    @IBAction func onFacebookSigninButton(sender: UIButton) {
        facebookLogin()
    }
    
    
    @IBAction func onFacebookSignupButton(sender: UIButton) {
        facebookLogin()
    }
    
    func facebookLogin(){
        self.loginManager!.logInWithReadPermissions(["public_profile"], fromViewController: self, handler: { (response:FBSDKLoginManagerLoginResult!, error: NSError!) in
            if(error == nil){
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
        })
    }
    
    
    func customEmailTextField(){
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.init(red: 155/255, green: 155/255, blue: 155/255, alpha: 1).CGColor
        border.frame = CGRect(x: 0, y: emailTextField.frame.size.height - width, width:  emailTextField.frame.size.width, height: emailTextField.frame.size.height)
        
        border.borderWidth = width
        emailTextField.layer.addSublayer(border)
        emailTextField.layer.masksToBounds = true
    }
    
    func customPasswordTextField(){
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.init(red: 155/255, green: 155/255, blue: 155/255, alpha: 1).CGColor
        border.frame = CGRect(x: 0, y: passwordTextField.frame.size.height - width, width:  passwordTextField.frame.size.width, height: passwordTextField.frame.size.height)
        
        border.borderWidth = width
        passwordTextField.layer.addSublayer(border)
        passwordTextField.layer.masksToBounds = true
    }
    
    func customNameTextField(){
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.init(red: 155/255, green: 155/255, blue: 155/255, alpha: 1).CGColor
        border.frame = CGRect(x: 0, y: nameTextField.frame.size.height - width, width:  nameTextField.frame.size.width, height: nameTextField.frame.size.height)
        
        border.borderWidth = width
        nameTextField.layer.addSublayer(border)
        nameTextField.layer.masksToBounds = true
    }
    
    @IBAction func unwindToThisViewController(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func onSegmentedPress(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            signinButton.hidden = false
            facebookSignin.hidden = false
            forgotDetailButton.hidden = false
            nameTextField.hidden = true
            signupButton.hidden = true
            facebookSignin.hidden = false
            facebookSignup.hidden = true
            self.emailTextField.text = ""
            self.passwordTextField.text = ""
            self.nameTextField.text = ""
            
        }else if sender.selectedSegmentIndex == 1{
            signinButton.hidden = true
            facebookSignin.hidden = true
            forgotDetailButton.hidden = true
            nameTextField.hidden = false
            signupButton.hidden = false
            facebookSignup.hidden = false
            signupButton.hidden = false
            self.emailTextField.text = ""
            self.passwordTextField.text = ""
            self.nameTextField.text = ""
            
        }
    }
}

extension UISegmentedControl {
    func removeBorders() {
        setBackgroundImage(imageWithColor(backgroundColor!), forState: .Normal, barMetrics: .Default)
        setBackgroundImage(imageWithColor(tintColor!), forState: .Selected, barMetrics: .Default)
        setDividerImage(imageWithColor(UIColor.clearColor()), forLeftSegmentState: .Normal, rightSegmentState: .Normal, barMetrics: .Default)
    }
    
    // create a 1x1 image with this color
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillRect(context, rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image
    }
    
    func setFontSize(fontSize: CGFloat) {
        
        let normalTextAttributes: [NSObject : AnyObject] = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont.systemFontOfSize(fontSize, weight: UIFontWeightRegular)
        ]
        
        let boldTextAttributes: [NSObject : AnyObject] = [
            NSForegroundColorAttributeName : UIColor.init(red: 37/255, green: 183/255, blue: 211/255, alpha: 1),
            NSFontAttributeName : UIFont.systemFontOfSize(fontSize, weight: UIFontWeightMedium),
            ]
        
        self.setTitleTextAttributes(normalTextAttributes, forState: .Normal)
        self.setTitleTextAttributes(normalTextAttributes, forState: .Highlighted)
        self.setTitleTextAttributes(boldTextAttributes, forState: .Selected)
    }
}
