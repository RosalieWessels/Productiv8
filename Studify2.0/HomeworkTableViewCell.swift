//
//  HomeworkTableViewCell.swift
//  Studify2.0
//
//  Created by Rosalie Wessels on 22/10/2018.
//  Copyright © 2018 RosalieW. All rights reserved.
//

import UIKit

class HomeworkTableViewCell: UITableViewCell {

    @IBOutlet weak var ColorImageView: UIImageView!
    @IBOutlet weak var HomeworkLabelView: UILabel!
    @IBOutlet weak var TeacherLabelView: UILabel!
    @IBOutlet weak var DateLabelView: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
