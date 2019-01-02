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
import NVActivityIndicatorView

class SignUpViewContoller : UIViewController, UITextViewDelegate {
    var activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView()
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBAction func SignupButtonPressed(_ sender: Any) {
        signUpButton.isEnabled = false
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        
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
        //activityIndicator.startAnimating()
        
        let loadingPacman = NVActivityIndicatorView(frame: CGRect(x: ((UIScreen.main.bounds.width/2)-25), y: ((UIScreen.main.bounds.height/2)-25), width: 50, height: 50), type: NVActivityIndicatorType(rawValue: 26), color: UIColor.white)
        self.view.addSubview(loadingPacman)
        loadingPacman.startAnimating()
        
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
                        
                        loadingPacman.stopAnimating()
                        //self.activityIndicator.stopAnimating()
                        
                        Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                            //Email Verification
                        })
                        
                        self.performSegue(withIdentifier: "signUpToHome", sender: self)
                        self.signUpButton.isEnabled = true
                    }
                }
                
            } else{
                print("Error when creating user: \(error!.localizedDescription)")
            }
        }
    }
}
