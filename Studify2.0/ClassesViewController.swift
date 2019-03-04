//
//  SecondViewController.swift
//  Studify2.0
//
//  Created by Rosalie Wessels on 13/10/2018.
//  Copyright © 2018 RosalieW. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import UIEmptyState

struct classesTableViewCellData {
    let className : String!
    let teacherName : String!
    let periodNumber : String!
}

class ClassesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIEmptyStateDataSource, UIEmptyStateDelegate{
    
    @IBOutlet weak var classesTableView: UITableView!
    
    var classesArray = [classesTableViewCellData]()
    
    var emptyStateTitle: NSAttributedString {
        let attrs = [NSAttributedStringKey.foregroundColor: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.00),
                     NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]
        return NSAttributedString(string: "Seems like you aren't signed up for any classes", attributes: attrs)
    }
    
    var emptyStateImage: UIImage? {
        return #imageLiteral(resourceName: "BooksWithoutWhite")
    }
    
    var emptyStateImageSize: CGSize? {
        return CGSize(width: 240, height: 240)
    }
    
    var emptyStateButtonTitle: NSAttributedString? {
        let attrs = [NSAttributedStringKey.foregroundColor: UIColor.white,
                     NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)]
        return NSAttributedString(string: "Check for Classes", attributes: attrs)
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
        classesArray.removeAll()
        DispatchQueue.main.async { self.classesTableView.reloadData()}
        getClasses()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.reloadEmptyStateForTableView(classesTableView)
    }

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
        
        self.emptyStateDataSource = self
        self.emptyStateDelegate = self
        
        getClasses()
        
        
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
        if period.lowercased().starts(with: "per. "){
            return String(period.dropFirst(5))
        }
        return period
    }
    func getClasses() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.listCourses() { (courses, error) in
            guard let courseList = courses else {
                print("Error listing courses: \(String(describing: error?.localizedDescription))")
                return
            }
            if let list = courseList.courses {
                for course in list {
                    print("Name", course.name!)
                    
                    //TODO: Sort the Classes on Period Number for in the TableView
                    //TODO: A way to make sure the correct teachers show up??
                    
                    appDelegate.listTeacher(courseId: course.identifier!) { (teachers, error) in
                        guard let teachersList = teachers else {
                            print("Error listing teachers: \(String(describing: error?.localizedDescription))")
                            return
                        }
                        if let leraren = teachersList.teachers {
                            for teacher in leraren {
                                print("teacher", teacher.profile!.name!.fullName!)
                                var cleanedPeriod = "--"
                                if course.section != nil{
                                    cleanedPeriod = self.cleanPeriod(period: course.section!)
                                }
                                self.classesArray += [classesTableViewCellData(className: course.name!, teacherName: teacher.profile?.name?.fullName!, periodNumber: cleanedPeriod)]
                                break
                            }
                        }
                        DispatchQueue.main.async { self.classesTableView.reloadData() }
                        DispatchQueue.main.async { self.reloadEmptyStateForTableView(self.classesTableView) }
                    }
                    print(course)
                }
                
            }
            
        }
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

