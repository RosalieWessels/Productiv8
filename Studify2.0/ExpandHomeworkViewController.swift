//
//  ExpandHomeworkViewController.swift
//  Studify2.0
//
//  Created by Rosalie Wessels on 27/10/2018.
//  Copyright © 2018 RosalieW. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ExpandHomeworkViewController: UIViewController {
    
    
    @IBOutlet weak var homeworkTitleTextView: UITextView!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var homeworkTitle = ""
    var dueDate = ""
    var HomeworkTitleAndIdentifier : [String : String] = ["" : ""]
    var homeworkIdentifier = ""
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.listCourses() { (courses, error) in
            guard let courseList = courses else {
                print("Error listing courses: \(String(describing: error?.localizedDescription))")
                return
            }
            if let list = courseList.courses {
                for course in list {
                    
                    appDelegate.listHomework(courseId: course.identifier!) { (homeworkResponse, error) in
                        guard let homeworkList = homeworkResponse else {
                            print("Error listing homework: \(error?.localizedDescription)")
                            return
                        }
                        if let huiswerk = homeworkList.courseWork {
                            
                            for work in huiswerk {
                                
//                                let homeworkIdentifierFromDictionary = self.HomeworkTitleAndIdentifier[self.homeworkTitle]
//
//                                if homeworkIdentifierFromDictionary == work.identifier {
//
//
//                                }
                                
                                if self.homeworkIdentifier == work.identifier {
                                    
                                    self.homeworkTitleTextView.text = work.title
                                    
                                    self.classLabel.text = course.name
                                    
                                    self.dueDateLabel.text = self.dueDate
                                    
                                    self.descriptionTextView.text = work.descriptionProperty
                                    
                                }
                                
                            }
                        }
                        
                        //Reload tableView spot
                    }
                    
                }
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
