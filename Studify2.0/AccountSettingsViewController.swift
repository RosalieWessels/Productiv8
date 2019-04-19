//
//  AccountSettingsViewController.swift
//  Studify2.0
//
//  Created by Rosalie Wessels on 20/10/2018.
//  Copyright © 2018 RosalieW. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class AccountSettingsViewController: UIViewController {
    
    @IBOutlet weak var deleteUserAccountButton: UIButton!
    @IBOutlet weak var accountSettingsView: UIView!
    @IBOutlet weak var studifyBackground: UIImageView!
    
    @IBOutlet weak var provideFeedbackButton: UIButton!
    
    var db : Firestore!
    
    @IBAction func reportBugPressed(_ sender: Any) {
        performSegue(withIdentifier: "reportBug", sender: self)
    }
    
    @IBAction func feedbackButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "provideFeedback", sender: self)
    }
    
    
    @IBAction func customizeButtonPressed(_ sender: Any) {
        print("customizeButton pressed")
        provideFeedbackButton.isEnabled = false
        performSegue(withIdentifier: "accountSettingsToCustomize", sender: self)
        
    }
    
    @IBAction func deleteUserAccountClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Delete User Account", message: "Are you sure you want to delete your account? Once it is deleted it cannot come back.", preferredStyle: .alert)
        
        let noAction = UIAlertAction(title: "No", style: .default) { (UIAlertAction) in
            self.userAccountNotDeleted()
        }
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
            self.userAccountDeleted()
        }
        
        alert.addAction(noAction)
        alert.addAction(yesAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateBackground()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        provideFeedbackButton.isEnabled = true
        deleteUserAccountButton.titleLabel?.adjustsFontSizeToFitWidth = true
        // Do any additional setup after loading the view, typically from a nib.
        accountSettingsView.layer.cornerRadius = 10
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func userAccountDeleted(){
        print("User account is going to be deleted")
        Auth.auth().currentUser?.delete { error in
            if let error = error {
                print(error)
            } else {
                print("Account Deletion Succesfull")
                let alert = UIAlertController(title: "Account is Deleted", message: "Your account is succesfully deleted", preferredStyle: .alert)
                let continueAction = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
                    self.userAccountisDeleted()
                }
                alert.addAction(continueAction)
                
                self.present(alert, animated: true, completion: nil)
                
                // Account deleted.
            }
        }
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
    
    func userAccountNotDeleted(){
        print("User account not deleted")
    }
    func userAccountisDeleted(){
        self.performSegue(withIdentifier: "userAccountSettingsToWelcomeScreen", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "accountSettingsToCustomize" {
            print("Going to Customize Viewcontroller")
        }
        else if segue.identifier == "reportBug" {
            let destinationViewController = segue.destination as! WebViewController
            destinationViewController.reason = "reportBug"
            
        }
        else if segue.identifier == "provideFeedback" {
            let destinationViewController = segue.destination as! WebViewController
            destinationViewController.reason = "provideFeedback"
        }
    }
}
