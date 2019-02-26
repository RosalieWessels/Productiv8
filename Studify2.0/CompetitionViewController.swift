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
        
        competitionData = [competitionTableViewCellData(numberPlace: "#1", userName: "Rosalie", numberOfAssignmentsCompleted: "20"), competitionTableViewCellData(numberPlace: "#2", userName: "Mahika", numberOfAssignmentsCompleted: "20")]
        
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
    
//    func makeScores() {
//        let competitionDatabase = db.collection("competitionDatabase")
//
//
//        db.collection("competitionDatabase").getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                print("Error getting documents: \(err)")
//            } else {
//                for document in querySnapshot!.documents {
//                    if let courseId = document.get("courseId") as? String {
//                        for (userName, time) in self.timeAndPersonDictionary {
//                            competitionDatabase.document(courseId).setData([
//                                "\(userName)Score" : time
//                                ])
//                        }
////                        competitionDatabase.getDocuments(courseId) { (querySnapshot. error) in
////                            if let error = error {
////                                print(error)
////                            } else {
////
////                            }
////
////                        }
//                    }
//                }
//            }
//        }
//
//        competitionDatabase.document("")
//
//
//        db.collection("competitionDatabase").getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                print("Error getting documents: \(err)")
//            } else {
//                for document in querySnapshot!.documents {
//                    if let score = document.get("score") as? [Int] {
//
//                    }
//                }
//            }
//        }
//
//        if let userName = Auth.auth().currentUser?.displayName {
//            competitionDatabase.document().setData([
//                "courseWorkId": ""
//                ])
//        }
//    }
    
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
        fastestPerson = Array(sortedTimeAndPersonDictionary.keys)[0]
        numberTwoPerson = Array(sortedTimeAndPersonDictionary.keys)[1]
        numberThreePerson = Array(sortedTimeAndPersonDictionary.keys)[2]
        
        
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
