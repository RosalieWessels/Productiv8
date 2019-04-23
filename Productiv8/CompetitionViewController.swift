//
//  CompetitionViewController.swift
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
import UIEmptyState

struct competitionTableViewCellData {
    
    let numberPlace : String!
    let userName : String!
    let numberOfAssignmentsCompleted : String!
    
}

class CompetitionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIEmptyStateDataSource, UIEmptyStateDelegate {
    
    @IBOutlet weak var competitionTableView: UITableView!
    @IBOutlet weak var classesLabel: UILabel!
    @IBOutlet weak var studifyBackground: UIImageView!
    
    var db : Firestore!
    
    var score = 0
    var courseID = ""
    var courseName = ""
    var timeTurnedIn = Date()
    
    var refreshControl = UIRefreshControl()
    
    var fastestTime = Date()
    var fastestPerson = ""
    var numberTwoTime = Date()
    var numberTwoPerson = ""
    var numberThreeTime = Date()
    var numberThreePerson = ""
    
    var emptyStateTitleToChange = "Select a class to see its leaderboard"
    
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
                        self.competitionData.removeAll()
                        DispatchQueue.main.async { self.competitionTableView.reloadData() }
                        self.courseName = classForLeaderboard
                        if self.courseName != "" {
                            self.getDataFromFirebase()
                        }
                    }
                }
                classesPicker.show()
            }
            
        }
    }
    
    var competitionData = [competitionTableViewCellData]()
    
    var numberOfHomeworkAssignmentsCompleted = Int()
    
    var emptyStateTitle: NSAttributedString {
        let attrs = [NSAttributedStringKey.foregroundColor: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.00),
                     NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20)]
        return NSAttributedString(string: "\(emptyStateTitleToChange)", attributes: attrs)
    }
    
    
    var emptyStateImage: UIImage? {
        return #imageLiteral(resourceName: "BooksWithoutWhite")
    }
    
    var emptyStateViewCanScroll: Bool {
        return true
    }
    
    var emptyStateViewSpacing: CGFloat {
        return 8
    }
    var emptyStateViewAdjustsToFitBars: Bool {
        return true
    }
    var emptyStateImageSize: CGSize? {
        return CGSize(width: 150, height: 150)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        classesLabel.adjustsFontSizeToFitWidth = true
        
        competitionTableView.delegate = self
        competitionTableView.dataSource = self

        competitionTableView.layer.cornerRadius = 10
        competitionTableView.layer.masksToBounds = true
        
        competitionData = [competitionTableViewCellData]()
        
        self.emptyStateDataSource = self
        self.emptyStateDelegate = self
        
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        
        let whiteColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        // create the attributed colour
        let attributedStringColor = [NSAttributedStringKey.foregroundColor : whiteColor];
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes : attributedStringColor )
        refreshControl.addTarget(self, action: #selector(doSomething), for: .valueChanged)
        refreshControl.tintColor = UIColor.white
        competitionTableView.refreshControl = refreshControl
        
    }
    
    @objc func doSomething(refreshControl: UIRefreshControl) {
        print("refreshing tableview")
        
        competitionData.removeAll(keepingCapacity: false)
        self.competitionTableView.reloadData()
        getDataFromFirebase()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateBackground()
        self.reloadEmptyStateForTableView(competitionTableView)
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
        
        self.reloadData()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
    
    func updateBackground() {
        if let userEmail = Auth.auth().currentUser?.email {
            let docRef = db.collection("customizeDatabase").document("\(userEmail)")
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    print("Document data: \(dataDescription)")
                    
                    let dictionary = document.data() as! [String : String]
                    
                    for (key, value) in dictionary {
                        print("\(key) -> \(value)")
                        if key == "background" {
                            if value == "blueAndYellow" {
                                self.studifyBackground.image = #imageLiteral(resourceName: "StudifyBackground")
                            }
                            else if value == "lightBlueAndPink" {
                                self.studifyBackground.image = #imageLiteral(resourceName: "StudifyBackgroundLightBlue&Pink")
                            }
                            else if value == "lightBlueAndOrange" {
                                self.studifyBackground.image = #imageLiteral(resourceName: "StudifyBackgroundLightBlue&Orange")
                            }
                        }
                    }
                } else {
                    print("Document does not exist... ERROR?")
                    
                }
            }
            
        }
    }
    
    func getDataFromFirebase() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.listCourses() { (courses, error) in
                    guard let courseList = courses else {
                        print("Error listing courses: \(String(describing: error?.localizedDescription))")
                        return
                    }
                    if let list = courseList.courses {
                        for course in list {
                            if course.name! == self.courseName {
                                self.courseID = course.identifier!
                                let docRef = self.db.collection("competitionDatabase").document("\(self.courseID)")
                                
                                docRef.getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                                        print("Document data: \(dataDescription)")

                                        let dictionary = document.data() as! [String : Int]
                                        
                                        let sortedDictionaryFinal = dictionary.sorted{ $0.value > $1.value }

                                        var place = 0
                                        for (key, value) in sortedDictionaryFinal {
                                            place = place + 1
                                            self.competitionData += [competitionTableViewCellData(numberPlace: "#\(place)", userName: "\(key)", numberOfAssignmentsCompleted: "\(value)")]
                                            DispatchQueue.main.async { self.competitionTableView.reloadData() }
                                            
                                            self.reloadData()
                                        }
                                    } else {
                                        print("Document does not exist")
                                        self.emptyStateTitleToChange = "We were unable to get the data"
                                        self.reloadData()
                                        
                                    }
                                }
                            }
                        }
                    }
                }
    }
    
    func reloadData() {
        self.refreshControl.endRefreshing()
        self.emptyStateTitleToChange = "We were unable to get the data"
        self.reloadEmptyStateForTableView(self.competitionTableView)
        // Reload empty view as well
        self.reloadEmptyStateForTableView(competitionTableView)
        
    }
    
}

//extension Dictionary where Value:Comparable {
//    var sortedByValue:[(Key,Value)] {return Array(self).sorted{$0.1 < $1.1}}
//}
//extension Dictionary where Key:Comparable {
//    var sortedByKey:[(Key,Value)] {return Array(self).sorted{$0.0 < $1.0}}
//}




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
