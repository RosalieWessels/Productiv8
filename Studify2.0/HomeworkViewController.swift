//
//  FirstViewController.swift
//  Studify2.0
//
//  Created by Rosalie Wessels on 13/10/2018.
//  Copyright © 2018 RosalieW. All rights reserved.
//

import UIKit
import Foundation
import FirebaseAuth
import Firebase
import FirebaseDatabase
import UIEmptyState

struct homeworkTableViewCellData : Equatable {
    let homeworkName : String!
    let className : String!
    let dateName : String!
    let colorImage : UIImage!
    let homeworkIdentifier : String!
    
    init(homeworkName : String!, className : String!, dateName : String!, colorImage : UIImage!, homeworkIdentifier : String!) {
        self.homeworkName = homeworkName
        self.className = className
        self.dateName = dateName
        self.colorImage = colorImage
        self.homeworkIdentifier = homeworkIdentifier
    }
    
    static func == (lhs: homeworkTableViewCellData, rhs: homeworkTableViewCellData) -> Bool {
        return lhs.homeworkName == rhs.homeworkName
    }
}

class HomeworkViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIEmptyStateDelegate, UIEmptyStateDataSource {
    
    @IBOutlet weak var homeworkTableView: UITableView!
    
    @IBAction func addHomeworkButton(_ sender: Any) {
        performSegue(withIdentifier: "homeworkScreenToInputHomework", sender: self)
    }
    
    @IBOutlet weak var addhomeworkButtonOutlet: UIButton!
    
    
    var homeworkArray = [homeworkTableViewCellData]()
    
    var homeworkTitleFromTableviewCell = ""
    var dueDateFromTableViewCell = ""
    var HomeworkTitleAndIdentifier : [String : String] = ["" : ""]
    var homeworkIdentifierFromTableViewCell = ""
    
    var emptyStateTitle: NSAttributedString {
        let attrs = [NSAttributedStringKey.foregroundColor: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.00),
                     NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20)]
        return NSAttributedString(string: "Seems like there is no homework!", attributes: attrs)
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
    
    var emptyStateButtonTitle: NSAttributedString? {
        let attrs = [NSAttributedStringKey.foregroundColor: UIColor.white,
                     NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)]
        return NSAttributedString(string: "Check for Homework", attributes: attrs)
    }
    
    var emptyStateButtonSize: CGSize? {
        return CGSize(width: 200, height: 40)
    }
    
    func emptyStateViewWillShow(view: UIView) {
        guard let emptyView = view as? UIEmptyStateView else { return }
        // Some custom button stuff
        emptyView.button.layer.cornerRadius = 5
        emptyView.button.layer.borderWidth = 1
        emptyView.button.layer.borderColor = UIColor.white.cgColor
        emptyView.button.layer.backgroundColor = UIColor.clear.cgColor
    }
    
    func emptyStatebuttonWasTapped(button: UIButton) {
        homeworkArray.removeAll()
        DispatchQueue.main.async { self.homeworkTableView.reloadData() }
        getHomework()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        homeworkArray.removeAll(keepingCapacity: false)
        self.homeworkTableView.reloadData()
        self.tabBarController?.navigationItem.hidesBackButton = true
        getHomework()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.reloadEmptyStateForTableView(homeworkTableView)
        addConstraintsToAddHomeworkButton()
    }
    
    func getDataAfterOpening() {
        homeworkArray.removeAll(keepingCapacity: false)
        self.homeworkTableView.reloadData()
        getHomework()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
        }else{
            print("Internet Connection not Available!")
            let alert = UIAlertController(title: "No internet...", message: "Seems like you are not connected to the internet. Unfortunately, Studify won't work without an internet connection. To make it work, connect to the wifi or enable data. Thank you.", preferredStyle: .alert)
            
            let closeAction = UIAlertAction(title: "Close", style: .default) { (UIAlertAction) in
                print("User closed no internet popup")
            }
            
            alert.addAction(closeAction)
            
            present(alert, animated: true, completion: nil)
        }
        
        homeworkTableView.delegate = self
        homeworkTableView.dataSource = self
        
        homeworkTableView.layer.cornerRadius = 10
        homeworkTableView.layer.masksToBounds = true
        
        self.emptyStateDataSource = self
        self.emptyStateDelegate = self
        
        homeworkTableView.register(HomeworkTableViewCell.self, forCellReuseIdentifier: "HomeworkTableViewCell")
        
        if Auth.auth().currentUser != nil {
            print("User is signed in")
        } else {
            performSegue(withIdentifier: "homeworkScreenToWelcomeScreen", sender: self)
        }
        
        
        
        
    }
    
    func addConstraintsToAddHomeworkButton() {

//        let height : CGFloat = self.calculateTopDistance()
//        
//        addhomeworkButtonOutlet.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            addhomeworkButtonOutlet.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20),
//            addhomeworkButtonOutlet.topAnchor.constraint(equalTo: view.topAnchor, constant: height + 10),
//            addhomeworkButtonOutlet.widthAnchor.constraint(equalToConstant: 45),
//            addhomeworkButtonOutlet.heightAnchor.constraint(equalToConstant: 75)
//            ])
        //addhomeworkButtonOutlet.edgesToSuperview(insets: .top(30) + .left(5) + .horizontal(20) + .vertical(50))
        
    }
    
    
    func getHomework() {
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
                                print("associated with developer \(work.associatedWithDeveloper)")
                                if work.dueDate == nil {
                                    self.homeworkArray += [homeworkTableViewCellData(homeworkName: work.title, className: course.name, dateName: "", colorImage: #imageLiteral(resourceName: "GreenImage"), homeworkIdentifier: work.identifier)]
                                } else if let dueDateDay = work.dueDate?.day {
                                    let dueDateDayInt = Int(truncating: dueDateDay)
                                    
                                    if let dueDateMonth = work.dueDate?.month {
                                        
                                        var dateComponents = DateComponents()
                                        dateComponents.year = 2019
                                        dateComponents.month = Int(truncating: dueDateMonth)
                                        dateComponents.day = dueDateDayInt
                                        dateComponents.hour = 12
                                        dateComponents.minute = 0
                                        dateComponents.second = 0
                                        dateComponents.timeZone = TimeZone(abbreviation: "UTC")
                                        
                                        if let year = work.dueDate?.year {
                                            dateComponents.year = Int(truncating: year)
                                        }
                                        
                                        if let hour = work.dueTime?.hours {
                                            dateComponents.hour = Int(truncating: hour)
                                        }
                                        
                                        if let minute = work.dueTime?.minutes {
                                            dateComponents.minute = Int(truncating: minute)
                                        }
                                        
                                        let userCalendar = Calendar.current // user calendar
                                        if let dueDate = userCalendar.date(from: dateComponents) {
                                            
                                            let currentDateTime = Date()
                                            
                                            appDelegate.listHomeworkState(courseId: course.identifier!, courseWorkId: work.identifier!) { (studentSubmissionResponse, error) in
                                                guard let submissionState = studentSubmissionResponse else {
                                                    print("Error listing submissionState: \(String(describing: error?.localizedDescription))")
                                                    return
                                                    
                                                }
                                                if let submissonStateOfHomework = submissionState.studentSubmissions {
                                                    print(submissonStateOfHomework)
                                                    for submission in submissonStateOfHomework {
                                                        print("\(submission.state), \(work.identifier!)")
                                                        if submission.state != nil {
                                                            let dateformatter = DateFormatter()
                                                            dateformatter.dateFormat = "MM/dd/yy"
                                                            let dueDateString = dateformatter.string(from: dueDate)
                                                            
                                                            //Setting this for the ExpandHomeworkViewController
                                                            self.dueDateFromTableViewCell = dueDateString
                                                            let homeworkName : String = work.title!
                                                            let homeworkIdentifier : String = work.identifier!
                                                            
                                                            self.HomeworkTitleAndIdentifier[homeworkName] = homeworkIdentifier
                                                            
                                                            
                                                            let currentDateRed = Calendar.current.date(byAdding: .day, value: 1, to: currentDateTime)
                                                            
                                                            let currentDateOrange = Calendar.current.date(byAdding: .day, value: 2, to: currentDateRed!)
                                                            
                                                            if dueDate <= currentDateRed! {
                                                                //Red
                                                                self.homeworkArray += [homeworkTableViewCellData(homeworkName: work.title, className: course.name, dateName: dueDateString, colorImage: #imageLiteral(resourceName: "RedImage"), homeworkIdentifier: work.identifier)]
                                                            }
                                                                
                                                            else if dueDate < currentDateOrange! {
                                                                //Orange
                                                                self.homeworkArray += [homeworkTableViewCellData(homeworkName: work.title, className: course.name, dateName: dueDateString, colorImage: #imageLiteral(resourceName: "OrangeImage"), homeworkIdentifier: work.identifier)]
                                                            }
                                                                
                                                            else{
                                                                //Green
                                                                self.homeworkArray += [homeworkTableViewCellData(homeworkName: work.title, className: course.name, dateName: dueDateString, colorImage: #imageLiteral(resourceName: "GreenImage"), homeworkIdentifier: work.identifier)]
                                                            }
                                                        }
                                                        break
                                                    }
                                                }
                                                
                                                //Spot of putting the Homework Assignments in the TableView BEFORE the submissionState was created
                                                if self.homeworkArray.count > 0 {
                                                    DispatchQueue.main.async { self.homeworkTableView.reloadData()}
                                                    DispatchQueue.main.async { self.reloadEmptyStateForTableView(self.homeworkTableView) }
                                                }
                                            }
                                        }
                                        
                                    }
                                }
                            }
                            
                        }
                        if self.homeworkArray.count > 0 {
                            DispatchQueue.main.async { self.homeworkTableView.reloadData() }
                            DispatchQueue.main.async { self.reloadEmptyStateForTableView(self.homeworkTableView) }
                        }
                        
                    }
                    
                    
                }
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homeworkArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Bundle.main.loadNibNamed("HomeworkTableViewCell", owner: self, options: nil)?.first as! HomeworkTableViewCell
        
        let noDuplicatesHomeworkArray = unique(homeworks: homeworkArray)
        
        cell.backgroundColor = UIColor.clear
        if indexPath.row >= 0 && indexPath.row < noDuplicatesHomeworkArray.count {
            cell.homeworkIdentifierLabel.text = noDuplicatesHomeworkArray[indexPath.row].homeworkIdentifier //Out of Range error??
            cell.homeworkLabelView.text = noDuplicatesHomeworkArray[indexPath.row].homeworkName
            cell.teacherLabelView.text = noDuplicatesHomeworkArray[indexPath.row].className
            cell.dateLabelView.text = noDuplicatesHomeworkArray[indexPath.row].dateName
            cell.colorImageView.image = noDuplicatesHomeworkArray[indexPath.row].colorImage
        }
        
        
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 67
    }
    
    var homeworkItem = ""
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        homeworkTitleFromTableviewCell = homeworkArray[indexPath.row].homeworkName
        homeworkIdentifierFromTableViewCell = homeworkArray[indexPath.row].homeworkIdentifier
        
        self.performSegue(withIdentifier: "homeworktoExpandHomework", sender: self)
        homeworkTableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func expandHomework(){
        self.performSegue(withIdentifier: "homeworktoExpandHomework", sender: self)
        
    }
    
    func inputHomework(){
        self.performSegue(withIdentifier: "homeworkScreenToInputHomework", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "homeworktoExpandHomework" {
            
            let destinationViewController = segue.destination as! ExpandHomeworkViewController
            
            destinationViewController.homeworkTitle = homeworkTitleFromTableviewCell
            destinationViewController.dueDate = dueDateFromTableViewCell
            destinationViewController.HomeworkTitleAndIdentifier = HomeworkTitleAndIdentifier
            destinationViewController.homeworkIdentifier = homeworkIdentifierFromTableViewCell
            
        }
    }
    
    func unique(homeworks: [homeworkTableViewCellData]) -> [homeworkTableViewCellData] {
        
        var uniqueHomeworkArray = [homeworkTableViewCellData]()
        
        for homework in homeworks {
            if !uniqueHomeworkArray.contains(homework) {
                uniqueHomeworkArray.append(homework)
            }
        }
        
        return uniqueHomeworkArray
    }
    
}


