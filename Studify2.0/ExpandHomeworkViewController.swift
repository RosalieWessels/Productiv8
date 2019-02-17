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
    
    var courseID : String = ""
    var courseWorkID : String = ""
    var studentSubmissionID : String = ""
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.turnInHomeworkAssignment(courseId: courseID, courseWorkId : courseWorkID, studentSubmissionId : studentSubmissionID) { (error) in
            if error != nil {
                print ("Error turning in Homework: \(String(describing: error?.localizedDescription))")
                return
            }
            
        }
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
                            print("Error listing homework: \(String(describing: error?.localizedDescription))")
                            return
                        }
                        if let huiswerk = homeworkList.courseWork {
                            
                            for work in huiswerk {
                                
                                if self.homeworkIdentifier == work.identifier {
                                    
                                    self.courseID = course.identifier!
                                    self.courseWorkID = work.identifier!
                                    
                                    appDelegate.listHomeworkState(courseId: course.identifier!, courseWorkId: work.identifier!) { (studentSubmissionResponse, error) in
                                        guard let submissionState = studentSubmissionResponse else {
                                            print("Error listing submissionState: \(String(describing: error?.localizedDescription))")
                                            return
                                            
                                        }
                                        if let submissonStateOfHomework = submissionState.studentSubmissions {
                                            for submission in submissonStateOfHomework {
                                                if let studentSubmission = submission.identifier {
                                                    self.studentSubmissionID = studentSubmission
                                                }
                                            }
                                        }
                                    }
                                    
                                    self.homeworkTitleTextView.text = work.title
                                    
                                    self.classLabel.text = course.name
                                    
                                    self.descriptionTextView.text = work.descriptionProperty
                                    
                                    if work.dueDate == nil {
                                        self.dueDateLabel.text
                                            = "Due Date Not Specified"
                                    }
                                    else {
                                        self.dueDateLabel.text = self.dueDate
                                    }
                                    
                                    
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
