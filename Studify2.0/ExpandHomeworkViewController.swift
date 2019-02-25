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
import FirebaseFirestore

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
    
    var timeAssignmentTurnedIn = Date()
    
    var db : Firestore!
    
    var score = 0
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.turnInHomeworkAssignment(courseId: courseID, courseWorkId : courseWorkID, studentSubmissionId : studentSubmissionID) { (error) in
            if error != nil {
                print ("Error turning in Homework: \(String(describing: error?.localizedDescription))")
                let alert = UIAlertController(title: "An error occured", message: "An error occured while trying to turn in your assignment.", preferredStyle: .alert)
                
                let closeAction = UIAlertAction(title: "Go To Homework Screen", style: .default) { (UIAlertAction) in
                    self.navigationController?.popViewController(animated: true)
                }
                
                alert.addAction(closeAction)
                
                self.present(alert, animated: true, completion: nil)
                return
            }
            if error == nil {
                
                self.getTimeAndScore()
                self.createDatabaseAndDocuments()
                
                let alert = UIAlertController(title: "Your assignment was turned in!", message: "Your assignment was successfully turned in!", preferredStyle: .alert)
                
                let closeAction = UIAlertAction(title: "Go To Homework Screen", style: .default) { (UIAlertAction) in
                    self.navigationController?.popViewController(animated: true)
                }
                
                alert.addAction(closeAction)
                
                self.present(alert, animated: true, completion: nil)
            }
            
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
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
    
    func getTimeAndScore() {
        let date = Date()
        let calendar = Calendar.current
        var components = DateComponents()
        
        components.second = calendar.component(.second, from: date)
        components.minute = calendar.component(.minute, from: date)
        components.hour = calendar.component(.hour, from: date)
        components.day = calendar.component(.day, from: date)
        components.month = calendar.component(.month, from: date)
        components.year = calendar.component(.year, from: date)
        
        timeAssignmentTurnedIn = calendar.date(from: components)!
    }
    
    func createDatabaseAndDocuments(){
        let competitionDatabase = db.collection("competitionDatabase")
        
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
                                
                                appDelegate.listHomeworkState(courseId: course.identifier!, courseWorkId: work.identifier!) { (studentSubmissionResponse, error) in
                                    guard let submissionState = studentSubmissionResponse else {
                                        print("Error listing submissionState: \(String(describing: error?.localizedDescription))")
                                        return
                                        
                                    }
                                    if let submissonStateOfHomework = submissionState.studentSubmissions {
                                        for submission in submissonStateOfHomework {
                                            if let userName = Auth.auth().currentUser?.displayName {
                                                competitionDatabase.document().setData([
                                                    "courseWorkId": work.identifier!,
                                                    "time": self.timeAssignmentTurnedIn,
                                                    "userName": userName,
                                                    "userId": submission.identifier!,
                                                    "courseId": course.identifier!
                                                    ])
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    
}
