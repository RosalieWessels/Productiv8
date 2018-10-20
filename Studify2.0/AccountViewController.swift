//
//  AccountViewController.swift
//  Studify2.0
//
//  Created by Rosalie Wessels on 14/10/2018.
//  Copyright © 2018 RosalieW. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth


class AccountViewContoller : UIViewController, UITextViewDelegate {
    var activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    
    
    @IBAction func LogOutPressed(_ sender: Any) {
        logOutButton.isEnabled = false
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        
        try! Auth.auth().signOut()
        if Auth.auth().currentUser == nil{
            print("Logout successful")
            performSegue(withIdentifier: "logOutToWelcomeScreen", sender: self)
            activityIndicator.stopAnimating()
            logOutButton.isEnabled = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let username = Auth.auth().currentUser?.displayName {
            usernameLabel.text = ("Username: \(username)")
        }
        
        if let email = Auth.auth().currentUser?.email {
            emailLabel.adjustsFontSizeToFitWidth = true
            emailLabel.text = ("Email: \(email)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}

