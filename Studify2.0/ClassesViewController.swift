//
//  SecondViewController.swift
//  Studify2.0
//
//  Created by Rosalie Wessels on 13/10/2018.
//  Copyright © 2018 RosalieW. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST

struct classesTableViewCellData {
    let className : String!
    let teacherName : String!
    let periodNumber : String!
}

class ClassesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var classesTableView: UITableView!
    
    var classesArray = [classesTableViewCellData]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //For the TableView
        
        classesTableView.delegate = self
        classesTableView.dataSource = self
        
        classesTableView.layer.cornerRadius = 10
        classesTableView.layer.masksToBounds = true
        
        classesArray = [classesTableViewCellData]()
        classesTableView.register(ClassesTableViewCell.self, forCellReuseIdentifier: "ClassesTableViewCell")
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.listCourses() { (courses, error) in
            guard let courseList = courses else {
                print("Error listing courses: \(error?.localizedDescription)")
                return
            }
            for course in (courseList.courses as! [GTLRClassroom_Course]!) {
                print("Name", course.name!)
                
                //TODO: Sort the Classes on Period Number for in the TableView
                
                appDelegate.listTeacher(courseId: course.identifier!) { (teachers, error) in
                    guard let teachersList = teachers else {
                        print("Error listing teachers: \(error?.localizedDescription)")
                        return
                    }
                    for teacher in (teachersList.teachers as! [GTLRClassroom_Teacher]!){
                        print("teacher", teacher.profile?.name?.fullName!)
                        var cleanedPeriod = "--"
                        if course.section != nil{
                            cleanedPeriod = self.cleanPeriod(period: course.section!)
                        }
                        self.classesArray += [classesTableViewCellData(className: course.name!, teacherName: teacher.profile?.name?.fullName!, periodNumber: cleanedPeriod)]
                        break
                    }
                }
                
                print(course)
            }
        }
    }
    
    func cleanPeriod (period : String) -> String {
        if period.lowercased().starts(with: "period "){
            return String(period.dropFirst(7))
        }
        if period.lowercased().hasSuffix("st period"){
            return String(period.dropLast(9))
        }
        if period.lowercased().hasSuffix("nd period"){
            return String(period.dropLast(9))
        }
        if period.lowercased().hasSuffix("rd period"){
            return String(period.dropLast(9))
        }
        if period.lowercased().hasSuffix("th period"){
            return String(period.dropLast(9))
        }
        return period
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return classesArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Bundle.main.loadNibNamed("ClassesTableViewCell", owner: self, options: nil)?.first as! ClassesTableViewCell
        
        cell.backgroundColor = UIColor.clear
        
        cell.classNameLabelView.text = classesArray[indexPath.row].className
        cell.teacherNameClassLabelView.text = classesArray[indexPath.row].teacherName
        cell.periodNumberLabelView.text = classesArray[indexPath.row].periodNumber
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 67
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        classesTableView.deselectRow(at: indexPath, animated: true)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}

