//
//  ExpandHomeworkViewController.swift
//
//  Created by Rosalie Wessels on 27/10/2018.
//  Copyright © 2018 RosalieW. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseDatabase
import GradientLoadingBar


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
    
    var usersWhoAreDone = 0
    var userPoints = 0
    var courseID : String = ""
    var courseWorkID : String = ""
    var studentSubmissionID : String = ""
    
    var timeAssignmentTurnedIn = Date()
    
    var score = 0
    
    let gradientLoadingBar = GradientLoadingBar(
        height: 4.0,
        durations: Durations(fadeIn: 1.5,
                             fadeOut: 2.0,
                             progress: 2.5),
        gradientColorList: [
            .red, .yellow, .green
        ],
        isRelativeToSafeArea: false
    )
    
    
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
        self.gradientLoadingBar.show()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.turnInHomeworkAssignment(courseId: courseID, courseWorkId : courseWorkID, studentSubmissionId : studentSubmissionID) { (error) in
            if error != nil {
                self.gradientLoadingBar.hide()
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
                self.createFirebaseClassDocument()
                //self.generateScores()
                //self.addScores()
                //self.updateFirebase()
                self.gradientLoadingBar.hide()
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
                    
                    if let userScore = document.get("\(username)") as? Int {
                        print(userScore)
                        self.generateScores()
                    } else {
                        docRef.updateData([
                            "\(username)": 0
                        ]) { err in
                            if let err = err {
                                print("Error updating document: \(err)")
                            } else {
                                print("Document successfully updated")
                                self.generateScores()
                            }
                        }

                    }
                    
                } else {
                    print("Document does not exist")
                    
                    print("Creating Document")
                    let newDocument = self.db.collection("competitionDatabase").document("\(self.courseID)")
                    
                    newDocument.setData([
                        "\(username)": 0
                    ])
                    print("Document with CourseID created")
                    self.generateScores()
                    
                }
            }
        }
        
    }
    
    func generateScores() {
        if let username = Auth.auth().currentUser?.displayName {
            let docRef = db.collection("competitionDatabase").document("\(homeworkIdentifier)")
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    print("Document data: \(dataDescription)")
                    
                    if let userDone = document.get("userDone") as? Int {
                        print(userDone)
                        self.usersWhoAreDone = userDone + 1
                        docRef.updateData([
                            "userDone" : self.usersWhoAreDone
                        ])
                        self.addScores()
                        
                    } else {
                        docRef.updateData([
                            "userDone": 1
                        ]) { err in
                            if let err = err {
                                print("Error updating document: \(err)")
                            } else {
                                print("Document successfully updated")
                                self.usersWhoAreDone = 1
                                self.addScores()
                            }
                        }
                        
                    }
                    
                } else {
                    print("Document does not exist")
                    
                    print("Creating Document")
                    let newDocument = self.db.collection("competitionDatabase").document("\(self.homeworkIdentifier)")
                    
                    newDocument.setData([
                        "userDone": 1
                        ])
                    
                    self.usersWhoAreDone = 1
                    
                    print("Document created with homeworkIdentifier")
                    self.addScores()
                    
                }
            }
        }
    }
    
    func addScores() {
        print("UsersWhoAreDone : \(usersWhoAreDone)")
        if usersWhoAreDone == 1 {
            userPoints = 3
        }
        else if usersWhoAreDone == 2 {
            userPoints = 2
        }
        else if usersWhoAreDone >= 3 {
            userPoints = 1
        }
        else {
            userPoints = 0
        }
        print("userpoints : \(userPoints)")
        updateFirebase()
    }
    
    func updateFirebase() {
        if let username = Auth.auth().currentUser?.displayName {
            let docRef = db.collection("competitionDatabase").document("\(courseID)")
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    print("Document data: \(dataDescription)")
                    
                    if let userScore = document.get("\(username)") as? Int {
                        print("userScore: \(userScore)")
                        let userScoreUpdated = userScore + self.userPoints
                        print("userScoreUpdated: \(userScoreUpdated)")
                        docRef.updateData([
                            "\(username)": userScoreUpdated
                        ]) { err in
                            if let err = err {
                                print("Error updating document: \(err)")
                            } else {
                                print("Score Document successfully updated")
                            }
                        }
                        
                    } else {
                        print("error getting userScore in updateFirebase()")
                    }
                    
                } else {
                    print("Document does not exist... error")
                    
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
    
    
    
}
