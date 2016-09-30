//
//  LoginViewController.swift
//  Locus
//
//  Created by Andre Suhartanto on 9/26/16.
//  Copyright © 2016 EndeJeje. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard)))
    }
    func dismissKeyboard() {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func loginOnPressedButton(sender: AnyObject) {
    
    guard let email = usernameTextField.text, let password = passwordTextField.text else {
        return
        }
        FIRAuth.auth()?.signInWithEmail(email, password: password) { (user, error) in
            if let person = user {
                
                NSUserDefaults.standardUserDefaults().setObject((user!.uid), forKey: "userUID")
                User.signIn(person.uid)
                self.performSegueWithIdentifier("HomeSegue", sender: nil)
            
            }else {
                let controller = UIAlertController(title: "Registration Failed", message: error?.localizedDescription, preferredStyle: .Alert)
                let dismissButton = UIAlertAction(title: "Try Again", style: .Default, handler: nil)
            
                controller.addAction(dismissButton)
        
                self.presentViewController(controller, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func unwindToThisViewController(segue: UIStoryboardSegue) {
    }
}
