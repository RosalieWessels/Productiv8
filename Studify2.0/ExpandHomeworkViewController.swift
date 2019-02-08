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

class ExpandHomeworkViewController: UIViewController {
    
    
    @IBOutlet weak var homeworkTitleTextView: UITextView!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var homeworkTitle = ""
    var dueDate = ""
    var dueDateNotString = Date()
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let homeworkController = HomeworkViewController()
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
                                
                                if work.title == self.homeworkTitle {
                                    
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
                                            
                                            let userCalendar = Calendar.current
                                            if let dueDateDate = userCalendar.date(from: dateComponents) {
                                                
                                                if dueDateDate == self.dueDateNotString {
                                                    
                                                    self.homeworkTitleTextView.text = work.title
                                                    
                                                    self.classLabel.text = course.name
                                                    
                                                    self.dueDateLabel.text = self.dueDate
                                                    
                                                    self.descriptionTextView.text = work.descriptionProperty
                                                    
                                                }
                                                
                                              
                                        
                                                
                                            }
                                        }
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
    
    
    
}
