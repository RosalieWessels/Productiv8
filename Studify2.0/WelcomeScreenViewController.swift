//
//  WelcomeScreenViewController.swift
//  Studify2.0
//
//  Created by Rosalie Wessels on 04/11/2018.
//  Copyright © 2018 RosalieW. All rights reserved.
//

import Foundation
import UIKit
import GoogleSignIn
import Firebase
import FirebaseAuth


class WelcomeScreenViewController: UIViewController, GIDSignInUIDelegate {
    
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        GIDSignIn.sharedInstance().uiDelegate = self
        // See https://firebase.google.com/docs/auth/ios/google-signin
        // Call signIn to sign in automatically (and fetch the Authorizer)
        // GIDSignIn.sharedInstance().signIn()
        
        if Auth.auth().currentUser != nil {
            performSegueToHomeworkScreen()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func performSegueToHomeworkScreen(){
        performSegue(withIdentifier: "WelcomeScreentoHomeworkScreen", sender: self)
    }
    
}

