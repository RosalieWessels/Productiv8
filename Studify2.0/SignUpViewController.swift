//
//  SignUpViewController.swift
//  Studify2.0
//
//  Created by Rosalie Wessels on 13/10/2018.
//  Copyright © 2018 RosalieW. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth

class SignUpViewContoller : UIViewController, UITextViewDelegate {
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBAction func SignupButtonPressed(_ sender: Any) {
        handleSignUp()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func handleSignUp() {
        guard let username = usernameField.text else {return}
        guard let email = emailField.text else {return}
        guard let password = passwordField.text else {return}
        
        Auth.auth().createUser(withEmail: email, password: password) {user, error in
            if error == nil && user != nil {
                print("User creation successful")
                
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = username
                changeRequest?.commitChanges {error in
                    if error == nil {
                        print("User display name changed")
                        let user = Auth.auth().currentUser?.displayName
                        let email = Auth.auth().currentUser?.email
                        print("Username: \(user), email: \(email)")
                        self.performSegue(withIdentifier: "signUpToHome", sender: self)
                    }
                }
                
            } else{
                print("Error when creating user: \(error!.localizedDescription)")
            }
        }
    }
}
