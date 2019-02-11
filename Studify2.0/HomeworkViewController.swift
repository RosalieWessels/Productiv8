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

struct homeworkTableViewCellData {
    let homeworkName : String!
    let className : String!
    let dateName : String!
    let colorImage : UIImage!
}

class HomeworkViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var homeworkTableView: UITableView!
    
    var homeworkArray = [homeworkTableViewCellData]()
    
    var homeworkTitleFromTableviewCell = ""
    var dueDateFromTableViewCell = ""
    var HomeworkTitleAndIdentifier : [String : String] = ["" : ""]
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.navigationItem.hidesBackButton = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeworkTableView.delegate = self
        homeworkTableView.dataSource = self
        
        homeworkTableView.layer.cornerRadius = 10
        homeworkTableView.layer.masksToBounds = true
        
        homeworkTableView.register(HomeworkTableViewCell.self, forCellReuseIdentifier: "HomeworkTableViewCell")
        
        homeworkArray = [homeworkTableViewCellData]()
        
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
                            print("Error listing homework: \(error?.localizedDescription)")
                            return
                        }
                        if let huiswerk = homeworkList.courseWork {
                            for work in huiswerk {
                                
                                if let dueDateDay = work.dueDate?.day {
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
                                            
                                            
                                            //TODO: Only display assignment when not done. Now done assignments are also shown
                                            if dueDate >= currentDateTime {
                                                
                                                
                                                
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
                                                    self.homeworkArray += [homeworkTableViewCellData(homeworkName: work.title, className: course.name, dateName: dueDateString, colorImage: #imageLiteral(resourceName: "RedImage"))]
                                                }
                                                    
                                                else if dueDate < currentDateOrange! {
                                                    //Orange
                                                    self.homeworkArray += [homeworkTableViewCellData(homeworkName: work.title, className: course.name, dateName: dueDateString, colorImage: #imageLiteral(resourceName: "OrangeImage"))]
                                                }
                                                    
                                                else{
                                                    //Green
                                                    self.homeworkArray += [homeworkTableViewCellData(homeworkName: work.title, className: course.name, dateName: dueDateString, colorImage: #imageLiteral(resourceName: "GreenImage"))]
                                                }
                                            }
                                        }
                                        
                                    }
                                }
                            }
                            
                        }
                        
                        DispatchQueue.main.async { self.homeworkTableView.reloadData() }
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
        
        
        cell.backgroundColor = UIColor.clear
        
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
        
        self.performSegue(withIdentifier: "homeworktoExpandHomework", sender: self)
        homeworkTableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func expandHomework(){
        self.performSegue(withIdentifier: "homeworktoExpandHomework", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "homeworktoExpandHomework" {
            
            let destinationViewController = segue.destination as! ExpandHomeworkViewController
            
            destinationViewController.homeworkTitle = homeworkTitleFromTableviewCell
            destinationViewController.dueDate = dueDateFromTableViewCell
            destinationViewController.HomeworkTitleAndIdentifier = HomeworkTitleAndIdentifier
            
        }
    }
    
}

