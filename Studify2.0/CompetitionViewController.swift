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

struct competitionTableViewCellData {
    
    let numberPlace : String!
    let userName : String!
    let numberOfAssignmentsCompleted : String!
    
}

class CompetitionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var competitionTableView: UITableView!
    @IBOutlet weak var classesLabel: UILabel!
    
    var db : Firestore!
    
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
                        self.classesLabel.text = "\(classForLeaderboard) Leaderboard"
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
                                                competitionDatabase.document(course.identifier!).setData([
                                                    "courseWorkId": work.identifier!,
                                                    "time": "",
                                                    "userName": userName,
                                                    "userId": submission.identifier!,
                                                    "score": 860000,
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
