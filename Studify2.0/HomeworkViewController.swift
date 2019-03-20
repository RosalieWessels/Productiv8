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

struct homeworkTableViewCellData {
    let homeworkName : String!
    let className : String!
    let dateName : String!
    let colorImage : UIImage!
    let homeworkIdentifier : String!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        homeworkTableView.delegate = self
        homeworkTableView.dataSource = self
        
        homeworkTableView.layer.cornerRadius = 10
        homeworkTableView.layer.masksToBounds = true
        
        self.emptyStateDataSource = self
        self.emptyStateDelegate = self
        
        homeworkTableView.register(HomeworkTableViewCell.self, forCellReuseIdentifier: "HomeworkTableViewCell")
        
        //homeworkArray = [homeworkTableViewCellData]()
        
        
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
                                print(work)
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
    
    func calculateTopDistance() -> CGFloat {
        
        /// Create view to measure
        let measureView: UIView = UIView()
        measureView.backgroundColor = .clear
        view.addSubview(measureView)
        
        /// Add needed constraints
        measureView.translatesAutoresizingMaskIntoConstraints = false
        measureView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        measureView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        measureView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        if let nav = navigationController {
            measureView.topAnchor.constraint(equalTo: nav.navigationBar.bottomAnchor).isActive = true
        } else {
            measureView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        }
        
        /// Force layout
        view.layoutIfNeeded()
        
        /// Calculate distance
        let distance = view.frame.size.height - measureView.frame.size.height
        
        /// Remove from superview
        measureView.removeFromSuperview()
        
        return distance
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homeworkArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Bundle.main.loadNibNamed("HomeworkTableViewCell", owner: self, options: nil)?.first as! HomeworkTableViewCell
        
        cell.backgroundColor = UIColor.clear
        cell.homeworkIdentifierLabel.text = homeworkArray[indexPath.row].homeworkIdentifier //Out of Range error??
        cell.homeworkLabelView.text = homeworkArray[indexPath.row].homeworkName
        cell.teacherLabelView.text = homeworkArray[indexPath.row].className
        cell.dateLabelView.text = homeworkArray[indexPath.row].dateName
        cell.colorImageView.image = homeworkArray[indexPath.row].colorImage
        
        
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
    
}
