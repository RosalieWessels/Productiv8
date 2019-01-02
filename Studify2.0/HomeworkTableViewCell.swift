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
    @IBOutlet weak var homeworkButtonView: UIButton!
    @IBOutlet weak var teacherLabelView: UILabel!
    @IBOutlet weak var dateLabelView: UILabel!
    @IBOutlet weak var homeworkLabelView: UILabel!
    
    @IBAction func homeworkButtonViewPressed(_ sender: Any) {
        //let segway = HomeworkViewController()
        //segway.expandHomework()
        
        
    }
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
