//
//  CustomizeViewController.swift
//  Studify2.0
//
//  Created by Rosalie Wessels on 4/10/19.
//  Copyright © 2019 RosalieW. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class CustomizeViewController : UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var blueAndyellowImage: UIImageView!
    @IBOutlet weak var lightBlueAndOrange: UIImageView!
    @IBOutlet weak var lightBlueAndPink: UIImageView!
    
    var db : Firestore!
    
    @IBOutlet weak var selectedBackgroundLabel: UILabel!
    var chosenBackground = ""
    
    @IBAction func customizeTitleTapped(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedBackgroundLabel.adjustsFontSizeToFitWidth = true
        
        blueAndyellowImage.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(blueAndYellowImageTapped(tapGestureRecognizer:)))
        blueAndyellowImage.addGestureRecognizer(tapGestureRecognizer)
        
        lightBlueAndOrange.isUserInteractionEnabled = true
        let tapGestureRecognizerTwo = UITapGestureRecognizer(target: self, action: #selector(lightBlueAndOrangeImageTapped(tapGestureRecognizer:)))
        lightBlueAndOrange.addGestureRecognizer(tapGestureRecognizerTwo)
        
        lightBlueAndPink.isUserInteractionEnabled = true
        let tapGestureRecognizer3 = UITapGestureRecognizer(target: self, action: #selector(lightBlueAndPinkImageTapped(tapGestureRecognizer:)))
        lightBlueAndPink.addGestureRecognizer(tapGestureRecognizer3)
        
//        let UITapRecognizerblueAndYellowImage = UITapGestureRecognizer(target: self, action: Selector(("blueAndYellowImageTapped:")))
//        UITapRecognizerblueAndYellowImage.delegate = self
//        self.blueAndyellowImage.addGestureRecognizer(UITapRecognizerblueAndYellowImage)
//        self.blueAndyellowImage.isUserInteractionEnabled = true
    }
    
    @objc func blueAndYellowImageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        print("blueandyellowImageTapped")
        // Your action
        selectedBackgroundLabel.text = "Blue and Yellow Background is selected"
    }
    
    @objc func lightBlueAndOrangeImageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        print("lightBlueAndOrangeTapped")
        // Your action
        selectedBackgroundLabel.text = "Light Blue and Orange Background is selected"
    }
    
    @objc func lightBlueAndPinkImageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        print("lightBlueAndPinkTapped")
        // Your action
        selectedBackgroundLabel.text = "Light Blue and Pink Background is selected"
    }
    
    func uploadChosenThemeToFirebase() {
    if let userEmail = Auth.auth().currentUser?.email {
        let docRef = db.collection("customizeDatabase").document("\(userEmail)")
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                
                docRef.updateData([
                    "background" : chosenBackground
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                        self.generateScores()
                    }
                }
                
            } else {
                print("Document does not exist")
                
                print("Creating Document")
                let newDocument = self.db.collection("customizeDatabase").document("\()")
                
                newDocument.setData([
                    "background": 0
                    ])
                print("Document with CourseID created")
                self.generateScores()
                
            }
        }
    }
    
}
