//
//  LogInViewController.swift
//  Studify2.0
//
//  Created by Rosalie Wessels on 13/10/2018.
//  Copyright © 2018 RosalieW. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth

class LogInViewContoller : UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func LogInPressed(_ sender: Any) {
        handleSignIn()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func handleSignIn(){
        guard let email = emailField.text else {return}
        guard let password = passwordField.text else{return}
        
        Auth.auth().signIn(withEmail: email, password: password) {user, error in
            if error == nil && user != nil{
                print("login succesfull")
                self.performSegue(withIdentifier: "logInToHome", sender: self)
                
            } else {
                print("Error logging in: \(error!.localizedDescription)")
            }
        }
        
    }
}
