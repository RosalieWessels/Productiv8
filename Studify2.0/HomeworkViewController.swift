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
                    print("Name", course.name!)
                    

                    appDelegate.listHomework(courseId: course.identifier!) { (homeworkResponse, error) in
                        guard let homeworkList = homeworkResponse else {
                            print("Error listing homework: \(error?.localizedDescription)")
                            return
                        }
                        if let huiswerk = homeworkList.courseWork {
                            for work in huiswerk {
                                print("homework", work)
                                
                                if let dueDateDay = work.dueDate?.day {
                                    let dueDateDayInt = Int(dueDateDay)
                                    
                                    if let dueDateMonth = work.dueDate?.month {
                                        
                                        var dateComponents = DateComponents()
                                        dateComponents.year = Int(work.dueDate!.year!)
                                        dateComponents.month = Int(dueDateMonth)
                                        dateComponents.day = dueDateDayInt
                                        //CRASHES WHEN THERE IS NO HOUR AND MINUTE SET, FIXING RIGHT NOW
                                        if case let dateComponents.hour = Int(work.dueTime!.hours!){
                                            
                                            if case let dateComponents.minute = Int(work.dueTime!.minutes!) {
                                                
                                                dateComponents.second = 59
                                                
                                                dateComponents.timeZone = TimeZone(abbreviation: "UTC")
                                                
                                                // Create date from components
                                                let userCalendar = Calendar.current // user calendar
                                                if let dueDate = userCalendar.date(from: dateComponents) {
                                                    print(dueDate)
                                                    
                                                    let currentDateTime = Date()
                                                    
                                                    //TODO: Only display assignment when not done
                                                    if dueDate >= currentDateTime {
                                                        
                                                        let dateformatter = DateFormatter()
                                                        dateformatter.dateFormat = "MM/dd/yy"
                                                        let dueDateString = dateformatter.string(from: dueDate)
                                                        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        var homeworkItem = homeworkArray[indexPath.row].homeworkName
        var className = homeworkArray[indexPath.row].className
        var dateLabel = homeworkArray[indexPath.row].dateName
        
        self.performSegue(withIdentifier: "homeworktoExpandHomework", sender: self)
        homeworkTableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func expandHomework(){
        self.performSegue(withIdentifier: "homeworktoExpandHomework", sender: self)
        
    }
    
}

