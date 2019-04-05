//
//  AddHomeworkViewController.swift
//  Studify2.0
//
//  Created by Rosalie Wessels on 19/02/2019.
//  Copyright © 2019 RosalieW. All rights reserved.
//

import Foundation
import UIKit
import TCPickerView
import IQKeyboardManagerSwift
import Firebase
import FirebaseFirestore
import GoogleSignIn
import GradientLoadingBar

class AddHomeworkViewController : UIViewController, UITextViewDelegate, UITextFieldDelegate
{
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextView! //It is a textView but I forgot to name it that way :)
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var chooseClassResultsLabel: UILabel!
    
    var classForHomework = ""
    var titleOfHW = ""
    var descriptionOfHW = ""
    var dueDateString = ""
    var courseId = ""
    
    var minuteOfDueDate = 0
    var hourOfDueDate = 0
    var dayOfDueDate = 0
    var monthOfDueDate = 0
    
    let gradientLoadingBar = GradientLoadingBar(
        height: 4.0,
        durations: Durations(fadeIn: 1.5,
                             fadeOut: 2.0,
                             progress: 2.5),
        gradientColorList: [
            .red, .yellow, .green
        ],
        isRelativeToSafeArea: true,
        onView :
    )
    
    var everythingFilledIn = true
    
    var partNotFilledInString = "Can't create assignment without"
    
    private let theme = TCPickerViewStudifyTheme()
    
    @IBAction func chooseClass(_ sender: Any) {
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
                        self.classForHomework = valuesOfPicker[selectedClass].title
                        for course in list {
                            if course.name == self.classForHomework {
                                self.courseId = course.identifier!
                            }
                        }
                        print(valuesOfPicker[selectedClass].title)
                        self.chooseClassResultsLabel.text = "\(self.classForHomework) is selected"
                        
                        
                    }
                }
                classesPicker.show()
            }
            
        }
    }
    
    @IBAction func dueDateChanged(_ sender: Any) {
        let dueDate = datePicker.date
        let calendar = Calendar.current
        
        let minute = calendar.component(.minute, from: dueDate)
        let hour = calendar.component(.hour, from: dueDate)
        let day = calendar.component(.day, from: dueDate)
        let month = calendar.component(.month, from: dueDate)
        
        minuteOfDueDate = minute
        hourOfDueDate = hour
        dayOfDueDate = day
        monthOfDueDate = month
        
    }
    
    @IBAction func addHomeworkButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Add Homework", message: "Are you sure you want to add this assignment to your Google Classroom Class?", preferredStyle: .alert)
        
        let noAction = UIAlertAction(title: "No", style: .default) { (UIAlertAction) in
            print("User did not want to add HW, popup")
        }
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
            self.getResultsFromAddHomework()
            self.addHomeworkToGoogleClassroom()
        }
        
        alert.addAction(noAction)
        alert.addAction(yesAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.delegate = self
        descriptionTextField.delegate = self
        
        titleTextField.placeholder = "Title"
        chooseClassResultsLabel.text = "*You must own this class*"
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        descriptionTextField.textColor = .lightGray
        descriptionTextField.text = "Description"
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        descriptionTextField.textColor = .black
        
        if descriptionTextField.text == "Description" {
            descriptionTextField.text = ""
        }
        
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if descriptionTextField.text == "" {
            descriptionTextField.textColor = .lightGray
            descriptionTextField.text = "Description"
        }
    }
    func getResultsFromAddHomework() {
        gradientLoadingBar.show()
        titleOfHW = titleTextField.text!
        descriptionOfHW = descriptionTextField.text!
        
        if descriptionOfHW == "Description" {
            descriptionOfHW = ""
        }
        
        print("title :\(titleOfHW)")
        print("class: \(classForHomework)")
        print("Description : \(descriptionOfHW)")
        print("Minute of DueDate : \(minuteOfDueDate), Hour of dueDate : \(hourOfDueDate), day : \(dayOfDueDate), month : \(monthOfDueDate)")
        
        
    }
    
    func addHomeworkToGoogleClassroom() {
        if titleOfHW == "" {
            if partNotFilledInString == "Can't create assignment without" {
                partNotFilledInString += " a title"
            }
            else {
                partNotFilledInString += ", a title"
            }
            everythingFilledIn = false
        }
        
        if descriptionOfHW == "" {
            if partNotFilledInString == "Can't create assignment without" {
                partNotFilledInString += " a description"
            }
            else {
                partNotFilledInString += ", a description"
            }
            everythingFilledIn = false
        }
        
        if courseId == "" {
            if partNotFilledInString == "Can't create assignment without" {
                partNotFilledInString += " a course"
            }
            else {
                partNotFilledInString += ", a course"
            }
            everythingFilledIn = false
        }
        if dayOfDueDate == 0 {
            if partNotFilledInString == "Can't create assignment without" {
                partNotFilledInString += " a due date"
            }
            else {
                partNotFilledInString += ", a due date"
            }
            everythingFilledIn = false
        }
        
        if everythingFilledIn == false {
            popupIfFieldsAreNotFilledIn()
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.courseworkCreate(workTitle: titleOfHW, workDescription: descriptionOfHW, workDueDateDay: dayOfDueDate, workDueDateMonth: monthOfDueDate, workDueDateHour: hourOfDueDate, workDueDateMinute: minuteOfDueDate, courseId: courseId) { (error) in
            if error != nil {
                print("Error turning in Homework : \(String(describing: error?.localizedDescription))")
                self.gradientLoadingBar.hide()
                self.errorDidOccurWhileCreatingAssignment()
            }
            if error == nil {
                self.self.gradientLoadingBar.hide()
                self.successfullyCreatedAssignment()
            }
        }
    }
    
    func popupIfFieldsAreNotFilledIn() {
        let alert = UIAlertController(title: "Not all fields where filled in", message: "The assignment can't be created when not all the fields are filled in. \(partNotFilledInString)", preferredStyle: .alert)
        
        let closeAction = UIAlertAction(title: "Close", style: .default) { (UIAlertAction) in
            print("User forgot to fill in some fields")
        }
        
        alert.addAction(closeAction)
        
        present(alert, animated: true, completion: nil)
        
        partNotFilledInString = "Can't create assignment without"
        everythingFilledIn = true
    }
    
    func errorDidOccurWhileCreatingAssignment() {
        let alert = UIAlertController(title: "An error occured", message: "We were unable to create the assignment. Does your internet work? Do you own the class? Check and then try again.", preferredStyle: .alert)
        
        let closeAction = UIAlertAction(title: "Close", style: .default) { (UIAlertAction) in
            print("User closed error occured popup")
        }
        
        alert.addAction(closeAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func successfullyCreatedAssignment(){
        let alert = UIAlertController(title: "Success!", message: "Your assignment was successfully created!", preferredStyle: .alert)
        
        let closeAction = UIAlertAction(title: "Go to Homework Screen", style: .default) { (UIAlertAction) in
            self.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(closeAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    
}
