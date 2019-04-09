//
//  HomeworkTableViewCell.swift
//  Studify2.0
//
//  Created by Rosalie Wessels on 22/10/2018.
//  Copyright © 2018 RosalieW. All rights reserved.
//

import UIKit
import Foundation

class HomeworkTableViewCell: UITableViewCell {

    
    @IBOutlet weak var colorImageView: UIImageView!
    @IBOutlet weak var teacherLabelView: UILabel!
    @IBOutlet weak var dateLabelView: UILabel!
    @IBOutlet weak var homeworkLabelView: UILabel!
    @IBOutlet weak var homeworkIdentifierLabel: UILabel!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        homeworkIdentifierLabel.isHidden = true
        teacherLabelView.adjustsFontSizeToFitWidth = true
        dateLabelView.adjustsFontSizeToFitWidth = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    func afterloadingXibFile(){
//        print("\(homeworkLabelView.text!) characters : \(homeworkLabelView.text!.count)")
//        if homeworkLabelView.text!.count < 25 {
//            homeworkLabelView.adjustsFontSizeToFitWidth = true
//
//        }
//        else {
//            homeworkLabelView.adjustsFontSizeToFitWidth = false
//        }
//    }
//
}
