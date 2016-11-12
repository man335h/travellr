//
//  ViewController.swift
//  Travellr
//
//  Created by Manish Gehani on 10/28/16.
//  Copyright © 2016 Manish Gehani. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth

class ViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
            self.performSegueWithIdentifier(SEGUE_PROFILE, sender: nil)
        }
    }

    @IBAction func fbBtnPressed(sender: UIButton!) {
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logInWithReadPermissions(["email"], fromViewController: self) { (facebookResult: FBSDKLoginManagerLoginResult!, facebookError: NSError!) in
            
            if facebookError != nil {
                print("FB login failed. Error: \(facebookError)")
            } else {
                                
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
                FIRAuth.auth()?.signInWithCredential(credential, completion: { (userLogin, error) in
                    if error != nil {
                        print("Login failed Error: \(error)")
                    } else {
                        print("We did it! \(userLogin)")
                        
                        //set up if-let
                        
                        let user = ["provider": credential.provider]
                        DataService.ds.createFirebaseUser((userLogin?.uid)!, user: user)
                        
                        NSUserDefaults.standardUserDefaults().setValue(userLogin?.uid, forKey: KEY_UID)
                        self.performSegueWithIdentifier(SEGUE_PROFILE, sender: nil)
                    }
                })
                
            }
        }
    }
    
    @IBAction func attemptLogin(sender: UIButton!) {
        if let email = emailField.text where email != "", let pwd = passwordField.text where pwd != "" {
            
            FIRAuth.auth()?.signInWithEmail(email, password: pwd, completion: { (user, error) in
                
                if error != nil {
                    if error?.code == STATUS_ACCT_NONEXIST {
                        FIRAuth.auth()?.createUserWithEmail(email, password: pwd, completion: { (createdUser, errorOnCreation) in
                            if errorOnCreation != nil {
                                if errorOnCreation!.code == STATUS_WEAK_PWD {
                                    self.showErrorAlert("Password too weak", msg: "Password must be at least 6 characters long")
                                } else {
                                    self.showErrorAlert("Error creating account", msg: "Could not create account. Please try again \(errorOnCreation)")
                                }
                            } else {
                                NSUserDefaults.standardUserDefaults().setValue(createdUser?.uid, forKey: KEY_UID)
                                FIRAuth.auth()?.signInWithEmail(email, password: pwd, completion: nil)
            
                                let user = ["provider": "password"]
                                DataService.ds.createFirebaseUser((createdUser?.uid)!, user: user)
                            
                                self.performSegueWithIdentifier(SEGUE_PROFILE, sender: nil)
                            }
                        })
                    } else if error?.code == STATUS_INVALID_EMAIL {
                        self.showErrorAlert("Invalid email", msg: "Please enter a valid email address")
                    } else if error?.code == STATUS_INCORRECT_PWD {
                        self.showErrorAlert("Unable to login", msg: "Incorrect login details")
                    } else {
                        self.showErrorAlert("Error", msg: "\(error)")
                    }
                } else {
                    self.performSegueWithIdentifier(SEGUE_PROFILE, sender: nil)
                }
            })
        } else {
            showErrorAlert("Details missing", msg: "Email and password required")
        }
    }
    
    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
}

