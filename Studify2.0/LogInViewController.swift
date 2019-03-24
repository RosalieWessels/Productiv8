//
//  LogInViewController.swift
//  Studify2.0
//
//  Created by Rosalie Wessels on 13/10/2018.
//  Copyright © 2018 RosalieW. All rights reserved.
//
//
import Foundation
import UIKit

class LogInViewContoller : UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var image = String()
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController!.navigationBar.topItem!.title = "Back"
    }
    
   override func viewDidLoad() {
       super.viewDidLoad()
        imageView.image = UIImage(named: image)
        //Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
         //Dispose of any resources that can be recreated.
    }


    func LogInToHomeworkscreenFunction(){
    self.performSegue(withIdentifier: "logInToHome", sender: self)
    }
}
