//
//  CustomizeViewController.swift
//
//  Created by Rosalie Wessels on 4/10/19.
//  Copyright © 2019 RosalieW. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase
import GoogleSignIn

class CustomizeViewController : UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var blueAndyellowImage: UIImageView!
    @IBOutlet weak var lightBlueAndOrange: UIImageView!
    @IBOutlet weak var lightBlueAndPink: UIImageView!
    @IBOutlet weak var studifyBackground: UIImageView!
    
    var db : Firestore!
    
    @IBOutlet weak var selectedBackgroundLabel: UILabel!
    var chosenBackground = ""
    
    @IBAction func customizeTitleTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Customize Productiv8", message: "To make Productiv8 extra cool, we have added a customization feature! Choose a background by clicking on one of the images and the app will automatically change every background to that one! The background is linked to your account (email address), so you can log in on any device with your account and you will still have your favorite background! More customization features coming soon!", preferredStyle: .alert)
        
        let closeAction = UIAlertAction(title: "Close", style: .default) { (UIAlertAction) in
            print("popupisclosed")
        }
        
        alert.addAction(closeAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateBackground()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedBackgroundLabel.adjustsFontSizeToFitWidth = true
        
        let settings = FirestoreSettings()
        
        
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        blueAndyellowImage.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(blueAndYellowImageTapped(tapGestureRecognizer:)))
        blueAndyellowImage.addGestureRecognizer(tapGestureRecognizer)
        
        lightBlueAndOrange.isUserInteractionEnabled = true
        let tapGestureRecognizerTwo = UITapGestureRecognizer(target: self, action: #selector(lightBlueAndOrangeImageTapped(tapGestureRecognizer:)))
        lightBlueAndOrange.addGestureRecognizer(tapGestureRecognizerTwo)
        
        lightBlueAndPink.isUserInteractionEnabled = true
        let tapGestureRecognizer3 = UITapGestureRecognizer(target: self, action: #selector(lightBlueAndPinkImageTapped(tapGestureRecognizer:)))
        lightBlueAndPink.addGestureRecognizer(tapGestureRecognizer3)
        
    }
    
    @objc func blueAndYellowImageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        print("blueandyellowImageTapped")
        // Your action
        selectedBackgroundLabel.text = "Blue and Yellow Background is selected"
        chosenBackground = "blueAndYellow"
        chosenBackgroundToFirebase()
        updateBackground()
    }
    
    @objc func lightBlueAndOrangeImageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        print("lightBlueAndOrangeTapped")
        // Your action
        selectedBackgroundLabel.text = "Light Blue and Orange Background is selected"
        chosenBackground = "lightBlueAndOrange"
        chosenBackgroundToFirebase()
        updateBackground()
    }
    
    @objc func lightBlueAndPinkImageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        print("lightBlueAndPinkTapped")
        // Your action
        selectedBackgroundLabel.text = "Light Blue and Pink Background is selected"
        chosenBackground = "lightBlueAndPink"
        chosenBackgroundToFirebase()
        updateBackground()
    }
    
    
    func chosenBackgroundToFirebase(){
        if let userEmail = Auth.auth().currentUser?.email {
            print(db)
            print("\(userEmail)")
            print("\(chosenBackground)")
            let newDocRef = db.collection("customizeDatabase").document("\(userEmail)")
            
            newDocRef.updateData([
                "background": "\(chosenBackground)"
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                    newDocRef.setData([
                        "background" : "\(self.chosenBackground)"
                    ])
                } else {
                    print("Document successfully updated")
                }
            }
        }
    }
    
    func updateBackground() {
        if let userEmail = Auth.auth().currentUser?.email {
            let docRef = self.db.collection("customizeDatabase").document("\(userEmail)")
            
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
