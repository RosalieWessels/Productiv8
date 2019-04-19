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
        self.navigationItem.title = "Welcome To Productiv8"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        for n in 0 ... 15 {
            imagesArray.append("Pexel\(n)")
        }
        
        //Commented because it doesn't work on older swift version
        if let randomElement = imagesArray.randomElement() {
            print(randomElement)
            imageView.image = UIImage(named: randomElement)
            randomElementForImage = randomElement
        }
        
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
        }else{
            print("Internet Connection not Available!")
            let alert = UIAlertController(title: "No internet...", message: "Seems like you are not connected to the internet. Unfortunately, Studify won't work without an internet connection. To make it work, connect to the wifi or enable data. Thank you.", preferredStyle: .alert)
            
            let closeAction = UIAlertAction(title: "Close", style: .default) { (UIAlertAction) in
                print("User closed no internet popup")
            }
            
            alert.addAction(closeAction)
            
            present(alert, animated: true, completion: nil)
        }
        
//        let randomIndex = Int(arc4random_uniform(UInt32(imagesArray.count)))
//        let randomItem = imagesArray[randomIndex]
//        imageView.image = UIImage(named: randomItem)
//        randomElementForImage = randomItem
        
        
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



