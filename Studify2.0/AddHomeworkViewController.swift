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

class AddHomeworkViewController : UIViewController, UITextViewDelegate, UITextFieldDelegate
{
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var chooseClassResultsLabel: UILabel!
    
    var classForHomework = ""
    
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
                        print(valuesOfPicker[selectedClass].title)
                        self.chooseClassResultsLabel.text = "\(self.classForHomework) is selected"
                        
                        
                    }
                }
                classesPicker.show()
            }
            
        }
    }
    @IBAction func addHomeworkButtonPressed(_ sender: Any) {
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
    
}
