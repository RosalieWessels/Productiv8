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

class AccountSettingsViewController: UIViewController {
    
    @IBOutlet weak var deleteUserAccountButton: UIButton!
    @IBOutlet weak var accountSettingsView: UIView!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    func userAccountNotDeleted(){
        print("User account not deleted")
    }
    func userAccountisDeleted(){
        self.performSegue(withIdentifier: "userAccountSettingsToWelcomeScreen", sender: self)
    }
}
