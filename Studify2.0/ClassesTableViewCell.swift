//
//  ClassesTableViewCell.swift
//  Studify2.0
//
//  Created by Rosalie Wessels on 03/01/2019.
//  Copyright © 2019 RosalieW. All rights reserved.
//

import UIKit

class ClassesTableViewCell: UITableViewCell {

    @IBOutlet weak var classNameLabelView: UILabel!
    @IBOutlet weak var teacherNameClassLabelView: UILabel!
    @IBOutlet weak var periodNumberLabelView: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
