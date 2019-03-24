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
    @IBOutlet weak var imageView: UIImageView!
    var imagesArray = [String]()
    var randomElementForImage = String()
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "Welcome To Studify"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for n in 0 ... 6 {
            imagesArray.append("Pexel\(n)")
        }
        
        if let randomElement = imagesArray.randomElement() {
            print(randomElement)
            imageView.image = UIImage(named: randomElement)
            randomElementForImage = randomElement
        }
        
        // Do any additional setup after loading the view, typically from a nib.
        
        GIDSignIn.sharedInstance().uiDelegate = self
        // See https://firebase.google.com/docs/auth/ios/google-signin
        // Call signIn to sign in automatically (and fetch the Authorizer)
        // GIDSignIn.sharedInstance().signIn()
        
        if Auth.auth().currentUser != nil {
            performSegueToHomeworkScreen()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "welcomeScreenToLogInScreen" {
            let logInScreen = segue.destination as! LogInViewContoller
            logInScreen.image = randomElementForImage
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

