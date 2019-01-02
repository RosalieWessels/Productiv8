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
        
        homeworkArray = [homeworkTableViewCellData(homeworkName: "HMH Math Lesson 3-2", className: "Math", dateName: "10/11", colorImage: #imageLiteral(resourceName: "GreenImage")), homeworkTableViewCellData(homeworkName: "Paragraph Outline", className: "History", dateName: "10/8", colorImage: #imageLiteral(resourceName: "OrangeImage")), homeworkTableViewCellData(homeworkName: "Chinese characters", className: "Chinese", dateName: "10/3", colorImage: #imageLiteral(resourceName: "RedImage"))]
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

