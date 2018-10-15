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
    var activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView()
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    
    @IBAction func LogInPressed(_ sender: Any) {
        logInButton.isEnabled = false
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        
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
        activityIndicator.startAnimating()
        guard let email = emailField.text else {return}
        guard let password = passwordField.text else{return}
        
        Auth.auth().signIn(withEmail: email, password: password) {user, error in
            if error == nil && user != nil{
                print("login succesfull")
                self.performSegue(withIdentifier: "logInToHome", sender: self)
                self.activityIndicator.stopAnimating()
                self.logInButton.isEnabled = true
            } else {
                print("Error logging in: \(error!.localizedDescription)")
            }
        }
        
    }
}
