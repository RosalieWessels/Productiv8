//
//  CompetitionViewController.swift
//  Studify2.0
//
//  Created by Rosalie Wessels on 03/01/2019.
//  Copyright © 2019 RosalieW. All rights reserved.
//

import Foundation
import UIKit
import TCPickerView
import GoogleSignIn
import Firebase
import FirebaseDatabase
import FirebaseFirestore

struct competitionTableViewCellData {
    
    let numberPlace : String!
    let userName : String!
    let numberOfAssignmentsCompleted : String!
    
}

class CompetitionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var competitionTableView: UITableView!
    @IBOutlet weak var classesLabel: UILabel!
    
    var db : Firestore!
    
    var score = 0
    var courseID = ""
    var courseName = ""
    var timeTurnedIn = Date()
    
    var fastestTime = Date()
    var fastestPerson = ""
    var numberTwoTime = Date()
    var numberTwoPerson = ""
    var numberThreeTime = Date()
    var numberThreePerson = ""
    
    var activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView()
    
    var timeAndPersonDictionary = [String : Date]()
    var sortedTimeAndPersonDictionary = [String : Date]()
    
    private let theme = TCPickerViewStudifyTheme()
    
    @IBAction func changeClassButtonPressed(_ sender: Any) {
        var classesPicker : TCPickerViewInput = TCPickerView()
        classesPicker.title = "Pick a class"
        
        var classes : [String] = []
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.listCourses() { (courses, error) in
            guard let courseList = courses else {
                print("Error listing courses: \(String(describing: error?.localizedDescription))")
                return
            }
            if let list = courseList.courses {
                for course in list {
                    classes.append(course.name!)
                }
                let valuesOfPicker = classes.map { TCPickerView.Value(title: $0)}
                classesPicker.values = valuesOfPicker
                classesPicker.delegate = self as? TCPickerViewOutput
                classesPicker.selection = .single
                classesPicker.theme = self.theme
                
                classesPicker.completion = { (selectedIndexes) in
                    for selectedClass in selectedIndexes {
                        let classForLeaderboard = valuesOfPicker[selectedClass].title
                        print(valuesOfPicker[selectedClass].title)
                        self.courseName = classForLeaderboard
                        self.classesLabel.text = "\(classForLeaderboard) Leaderboard"
                        if self.courseName != "" {
                            self.fetchTimeAndUserFromFirebase()
                            self.compareTimes()
                            print(self.sortedTimeAndPersonDictionary)
                            self.makeScores()
                            self.useDataforTableview()
                        }
                    }
                }
                classesPicker.show()
            }
            
        }
    }
    
    var competitionData = [competitionTableViewCellData]()
    
    var numberOfHomeworkAssignmentsCompleted = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        classesLabel.adjustsFontSizeToFitWidth = true
        
        competitionTableView.delegate = self
        competitionTableView.dataSource = self

        competitionTableView.layer.cornerRadius = 10
        competitionTableView.layer.masksToBounds = true
        
        competitionData = [competitionTableViewCellData]()
        
        
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return competitionData.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Bundle.main.loadNibNamed("CompetitionTableViewCell", owner: self, options: nil)?.first as! CompetitionTableViewCell
        
        cell.backgroundColor = UIColor.clear
        cell.namePlace.text = competitionData[indexPath.row].numberPlace
        cell.userName.text = competitionData[indexPath.row].userName
        cell.numberOfAssignmentsCompleted.text = competitionData[indexPath.row].numberOfAssignmentsCompleted
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }

    
    func fetchTimeAndUserFromFirebase() {
        
//        self.activityIndicator.center = self.view.center
//        self.activityIndicator.hidesWhenStopped = true
//        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
//        self.view.addSubview(activityIndicator)
//        self.activityIndicator.startAnimating()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.listCourses() { (courses, error) in
            guard let courseList = courses else {
                print("Error listing courses: \(String(describing: error?.localizedDescription))")
                return
            }
            if let list = courseList.courses {
                for course in list {
                    if course.name! == self.courseName {
                        self.db.collection("competitionDatabase").whereField("courseId", isEqualTo: course.identifier!)
                            .getDocuments() { (querySnapshot, error) in
                                if let error = error {
                                    print("Error getting documents: \(error)")
                                } else {
                                    for document in querySnapshot!.documents {
                                        print("\(document.documentID) => \(document.data())")
                                        //ADD CODE TO THOSE DOCUMENTS
                                        if let time = document.get("time") as? Date {
                                            if let userName = document.get("userName") as? [String] {
                                                self.timeAndPersonDictionary["\(userName)"] = time
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        
//        self.activityIndicator.stopAnimating()
    }
    
    func compareTimes(){
        let sortedDates = Array(timeAndPersonDictionary.values).sorted(by: { $0.compare($1) == .orderedAscending })
        for (person, time) in timeAndPersonDictionary {
            for sortedTime in sortedDates {
                if time == sortedTime {
                    sortedTimeAndPersonDictionary["\(person)"] = time
                }
            }
        }
        
    }
    
    func makeScores() {
        
        let competitionDatabase = db.collection("competitionDatabase")
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.listCourses() { (courses, error) in
            guard let courseList = courses else {
                print("Error listing courses: \(String(describing: error?.localizedDescription))")
                return
            }
            if let list = courseList.courses {
                for course in list {
                    if self.courseName == course.name {
                        
                        self.courseID = course.identifier!
                        //Create document with course Identifier + Scores
                        competitionDatabase.document("\(course.identifier!)Scores").setData([
                            "Default" : 0 //Change in a way??
                        ]) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                print("Document successfully written!")
                                
                                let competitionDatabaseCourseIdScores = self.db.collection("competitionDatabase").document("\(course.identifier!)Scores")
                                
                                for (name, time) in self.sortedTimeAndPersonDictionary {
                                    print("Got inside dictionary")
                                    self.timeTurnedIn = time
                                    competitionDatabaseCourseIdScores.getDocument { (document, error) in
                                        if let document = document, document.exists {
                                            print("Got the Document")
                                            let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                                            print("Document data: \(dataDescription)")
                                            
                                            if let score = document.get("\(name)Score") as? Int {
                                                if name == Array(self.sortedTimeAndPersonDictionary.keys)[0] {
                                                    competitionDatabase.document("\(course.identifier!)Scores").updateData([
                                                        "\(name)" : score + 3
                                                        ])
                                                }
                                                else if name == Array(self.sortedTimeAndPersonDictionary.keys)[1] {
                                                    competitionDatabase.document("\(course.identifier!)Scores").updateData([
                                                        "\(name)" : score + 2
                                                        ])
                                                }
                                                else {
                                                    competitionDatabase.document("\(course.identifier!)Scores").updateData([
                                                        "\(name)" : score + 1
                                                        ])
                                                }
                                            }
                                            else {
                                                if name == Array(self.sortedTimeAndPersonDictionary.keys)[0] {
                                                    competitionDatabase.document("\(course.identifier!)Scores").updateData([
                                                        "\(name)" : 3
                                                        ])
                                                }
                                                else if name == Array(self.sortedTimeAndPersonDictionary.keys)[1] {
                                                    competitionDatabase.document("\(course.identifier!)Scores").updateData([
                                                        "\(name)" : 2
                                                        ])
                                                }
                                                else {
                                                    competitionDatabase.document("\(course.identifier!)Scores").updateData([
                                                        "\(name)" : 1
                                                        ])
                                                }
                                            }
                                            
                                        } else {
                                            print("Document does not exist")
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
    
    func useDataforTableview() {
        let competitionDatabaseCourseIdScores = self.db.collection("competitionDatabase").document("\(courseID)Scores")
        
        competitionDatabaseCourseIdScores.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                
                let firestoreResults = document.data() as! [String : Int]
                var place = 0
                
                for (name, score) in firestoreResults {
                    place = place + 1
                    self.competitionData += [competitionTableViewCellData(numberPlace: "#\(place)", userName: "\(name)", numberOfAssignmentsCompleted: "\(score)")]
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
}

public final class TCPickerViewStudifyTheme: TCPickerViewThemeType {
    
    public let textColor: UIColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    public let grayColor: UIColor = UIColor(red: 169/255, green: 169/255, blue: 169/255, alpha: 1)
    public let darkGrayColor: UIColor = UIColor(red: 105/255, green: 105/255, blue: 105/255, alpha: 1)
    
    public var doneText: String {
        return "Done"
    }
    
    public var closeText: String {
        return "Cancel"
    }
    
    public var backgroundColor: UIColor {
        return self.textColor
    }
    
    public var titleColor: UIColor {
        return self.textColor
    }
    
    public var doneTextColor: UIColor {
        return self.textColor
    }
    
    public var closeTextColor: UIColor {
        return self.textColor
    }
    
    public var headerBackgroundColor: UIColor {
        return self.darkGrayColor
    }
    
    public var doneBackgroundColor: UIColor {
        return self.darkGrayColor
    }
    
    public var closeBackgroundColor: UIColor {
        return self.grayColor
    }
    
    public var separatorColor: UIColor {
        return self.textColor
    }
    
    public var buttonsFont: UIFont {
        return UIFont.systemFont(ofSize: 15)
    }
    
    public var titleFont: UIFont{
        return UIFont.boldSystemFont(ofSize: 17)
    }
    
    public var rowHeight: CGFloat {
        return 50
    }
    
    public var cornerRadius: CGFloat {
        return 8.0
    }
    
    
    public required init() {}
}
