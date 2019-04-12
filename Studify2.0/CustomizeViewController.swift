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
import FirebaseDatabase
import UIKit

class CustomizeViewController : UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
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
        
    }
    
    @objc func blueAndYellowImageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        print("blueandyellowImageTapped")
        // Your action
        selectedBackgroundLabel.text = "Blue and Yellow Background is selected"
        chosenBackground = "blueAndYellow"
        uploadChosenThemeToFirebase()
    }
    
    @objc func lightBlueAndOrangeImageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        print("lightBlueAndOrangeTapped")
        // Your action
        selectedBackgroundLabel.text = "Light Blue and Orange Background is selected"
        chosenBackground = "lightBlueAndOrange"
        uploadChosenThemeToFirebase()
    }
    
    @objc func lightBlueAndPinkImageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        print("lightBlueAndPinkTapped")
        // Your action
        selectedBackgroundLabel.text = "Light Blue and Pink Background is selected"
        chosenBackground = "lightBlueAndPink"
        uploadChosenThemeToFirebase()
    }
    
    func uploadChosenThemeToFirebase() {
        if let userName = Auth.auth().currentUser?.displayName {
            print("username : \(userName)")
            let docRef = db.collection("customizeDatabase").document("\(userName)")
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    print("Document data: \(dataDescription)")
                    
                    docRef.updateData([
                        "background" : self.chosenBackground
                    ]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                            self.reload()
                        }
                    }
                    
                } else {
                    print("Document does not exist")
                    
                    print("Creating Document")
                    let newDocument = self.db.collection("customizeDatabase").document("\(userName)")
                    
                    newDocument.setData([
                        "background": self.chosenBackground
                        ])
                    print("Document with CourseID created")
                    
                }
            }
        }
    }
    
    func reload(){
        if let userName = Auth.auth().currentUser?.displayName {
            let docRef = db.collection("customizeDatabase").document("\(userName)")
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    print("Document data: \(dataDescription)")
                    
                    if let background = document.get("background") as? String {
                        print(background)
                        if background == "lightBlueAndPink" {
                            self.backgroundImageView.image = #imageLiteral(resourceName: "StudifyBackgroundLightBlue&Pink")
                        }
                        else if background == "lightBlueAndOrange" {
                            self.backgroundImageView.image = #imageLiteral(resourceName: "StudifyBackgroundLightBlue&Orange")
                        }
                        else if background == "blueAndYellow" {
                            self.backgroundImageView.image = #imageLiteral(resourceName: "StudifyBackground")
                        }
                        
                        
                    } else {
                        print("No member Background")
                    }
                    
                } else {
                    print("No document with username")
                }
            }
        }
    }
    
}
