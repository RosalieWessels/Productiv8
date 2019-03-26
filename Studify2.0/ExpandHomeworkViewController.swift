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
import FirebaseDatabase


class ExpandHomeworkViewController: UIViewController {
    

    @IBOutlet weak var homeworkButtonAndLabel: UIButton!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var descriptionButtonAndLabel: UIButton!
    
    var db : Firestore!

    
    var homeworkTitle = ""
    var dueDate = ""
    var HomeworkTitleAndIdentifier : [String : String] = ["" : ""]
    var homeworkIdentifier = ""
    var descriptionForHomework = ""
    
    var courseID : String = ""
    var courseWorkID : String = ""
    var studentSubmissionID : String = ""
    
    var timeAssignmentTurnedIn = Date()
    
    var score = 0
    
    @IBAction func homeworkButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Homework Title", message: "\(homeworkTitle)", preferredStyle: .alert)
        
        let closeAction = UIAlertAction(title: "Close", style: .default) { (UIAlertAction) in
            print("User closed expand homework title")
        }
        
        alert.addAction(closeAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func descriptionButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Description", message: "\(descriptionForHomework)", preferredStyle: .alert)
        
        let closeAction = UIAlertAction(title: "Close", style: .default) { (UIAlertAction) in
            print("User closed expand description")
        }
        
        alert.addAction(closeAction)
        
        
        present(alert, animated: true, completion: nil)
    }
    
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
                
//                self.getTimeAndScore()
//                self.createDatabaseAndDocuments()
                
                let alert = UIAlertController(title: "Your assignment was turned in!", message: "Your assignment was successfully turned in!", preferredStyle: .alert)
                
                let closeAction = UIAlertAction(title: "Go To Homework Screen", style: .default) { (UIAlertAction) in
                    self.navigationController?.popViewController(animated: true)
                }
                
                alert.addAction(closeAction)
                
                self.present(alert, animated: true, completion: nil)
            }
            
        }
        
        
    }
    
    func createFirebaseClassDocument() {
        if let username = Auth.auth().currentUser?.displayName {
            let docRef = db.collection("competitionDatabase").document("\(courseID)")
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    print("Document data: \(dataDescription)")
                    docRef.updateData([
                        "\(\(username))": 0
                    ]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                        }
                    }
                } else {
                    print("Document does not exist")
                    
                    let newCityRef = db.collection("cities").document()
                    
                    // later...
                    newCityRef.setData([
                        // ...
                        ])
                    
                    
                    db.collection("competitionDatabase").addDocument("\(courseID)")(data: [
                        "\(username)": 0
                    ]) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            print("Document added with ID: \(ref!.documentID)")
                        }
                    }
                }
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
                                    
                                    
                                    self.homeworkTitle = work.title!
                                    self.homeworkIdentifier = work.identifier!
                                    
                                    if work.descriptionProperty != nil {
                                        self.descriptionForHomework = work.descriptionProperty!
                                    }
                                    
                                    self.homeworkButtonAndLabel.setTitle("\(self.homeworkTitle)", for: .normal)
                                    self.descriptionButtonAndLabel.setTitle("\(self.descriptionForHomework)", for: .normal)
                                    
                                    self.classLabel.text = course.name!
                                    
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
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func getTimeAndScore() {
//        let date = Date()
//        let calendar = Calendar.current
//        var components = DateComponents()
//
//        components.second = calendar.component(.second, from: date)
//        components.minute = calendar.component(.minute, from: date)
//        components.hour = calendar.component(.hour, from: date)
//        components.day = calendar.component(.day, from: date)
//        components.month = calendar.component(.month, from: date)
//        components.year = calendar.component(.year, from: date)
//
//        timeAssignmentTurnedIn = calendar.date(from: components)!
//        print("timeTurnedin: \(timeAssignmentTurnedIn)")
//    }
//
//    func createDatabaseAndDocuments(){
//        let competitionDatabase = db.collection("competitionDatabase")
//
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        appDelegate.listCourses() { (courses, error) in
//            guard let courseList = courses else {
//                print("Error listing courses: \(String(describing: error?.localizedDescription))")
//                return
//            }
//            if let list = courseList.courses {
//                for course in list {
//
//
//
//                    appDelegate.listHomework(courseId: course.identifier!) { (homeworkResponse, error) in
//                        guard let homeworkList = homeworkResponse else {
//                            print("Error listing homework: \(String(describing: error?.localizedDescription))")
//                            return
//                        }
//                        if let huiswerk = homeworkList.courseWork {
//
//                            for work in huiswerk {
//
//                                if work.identifier! == self.homeworkIdentifier {
//                                    if let userName = Auth.auth().currentUser?.displayName {
//                                        competitionDatabase.document().setData([
//                                            "courseWorkId": work.identifier!,
//                                            "time": self.timeAssignmentTurnedIn,
//                                            "userName": userName,
//                                            "courseId": course.identifier!
//                                            ])
//                                    }
//                                }
//
//
////                                appDelegate.listHomeworkState(courseId: course.identifier!, courseWorkId: work.identifier!) { (studentSubmissionResponse, error) in
////                                    guard let submissionState = studentSubmissionResponse else {
////                                        print("Error listing submissionState: \(String(describing: error?.localizedDescription))")
////                                        return
////
////                                    }
////                                    print("timeTurnedIn: \(self.timeAssignmentTurnedIn)")
////                                    if let submissonStateOfHomework = submissionState.studentSubmissions {
////                                        print(submissonStateOfHomework)
////                                        for submission in submissonStateOfHomework {
////                                            if let userName = Auth.auth().currentUser?.displayName {
////                                                competitionDatabase.document().setData([
////                                                    "courseWorkId": work.identifier!,
////                                                    "time": self.timeAssignmentTurnedIn,
////                                                    "userName": userName,
////                                                    "userId": submission.identifier!,
////                                                    "courseId": course.identifier!
////                                                    ])
////                                            }
////                                        }
////                                    }
////
////                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    
    
}
