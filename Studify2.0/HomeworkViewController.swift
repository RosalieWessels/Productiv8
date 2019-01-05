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
        
        //TODO: Change the course ID
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.listHomework(courseId: "15157388313") { (homeworkResponse, error) in
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
                            dateComponents.hour = 23
                            dateComponents.minute = 59
                            dateComponents.second = 59
                            
                            // Create date from components
                            let userCalendar = Calendar.current // user calendar
                            if let dueDate = userCalendar.date(from: dateComponents) {
                                print(dueDate)
                                
                                let currentDateTime = Date()
                                
                                if dueDate >= currentDateTime {
                                    
                                    let dateformatter = DateFormatter()
                                    dateformatter.dateFormat = "MM/dd/yy"
                                    let dueDateString = dateformatter.string(from: dueDate)
                                    
                                    self.homeworkArray += [homeworkTableViewCellData(homeworkName: work.title, className: work.courseId, dateName: dueDateString, colorImage: #imageLiteral(resourceName: "GreenImage"))]
                                    
                                }
                            }
                        }
                    }
                }
                
            }
            
            DispatchQueue.main.async { self.homeworkTableView.reloadData() }
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

