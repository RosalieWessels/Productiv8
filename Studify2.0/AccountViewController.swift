
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
import FirebaseFirestore
import GoogleSignIn
import GoogleToolboxForMac


class AccountViewContoller : UIViewController, UITextViewDelegate {
    var activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    @IBOutlet weak var accountView: UIView!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var studifyBackground: UIImageView!
    
    @IBOutlet weak var accountLabel2: UILabel!
    
    var db : Firestore!
    
    @IBAction func LogOutPressed(_ sender: Any) {
        logOutButton.isEnabled = false
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        
        try! Auth.auth().signOut()
        try GIDSignIn.sharedInstance().signOut()
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
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        accountLabel2.adjustsFontSizeToFitWidth = true
        accountView.layer.cornerRadius = 10
        if let username = Auth.auth().currentUser?.displayName {
            usernameLabel.text = ("Username: \(username)")
        }
        
        if let email = Auth.auth().currentUser?.email {
            emailLabel.adjustsFontSizeToFitWidth = true
            emailLabel.text = ("Email: \(email)")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateBackground()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateBackground() {
        if let userEmail = Auth.auth().currentUser?.email {
            let docRef = db.collection("customizeDatabase").document("\(userEmail)")
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    print("Document data: \(dataDescription)")
                    
                    let dictionary = document.data() as! [String : String]
                    
                    for (key, value) in dictionary {
                        print("\(key) -> \(value)")
                        if key == "background" {
                            if value == "blueAndYellow" {
                                self.studifyBackground.image = #imageLiteral(resourceName: "StudifyBackground")
                            }
                            else if value == "lightBlueAndPink" {
                                self.studifyBackground.image = #imageLiteral(resourceName: "StudifyBackgroundLightBlue&Pink")
                            }
                            else if value == "lightBlueAndOrange" {
                                self.studifyBackground.image = #imageLiteral(resourceName: "StudifyBackgroundLightBlue&Orange")
                            }
                        }
                    }
                } else {
                    print("Document does not exist... ERROR?")
                    
                }
            }
            
        }
    }
    
    
}

