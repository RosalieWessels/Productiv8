//
//  CompetitionTableViewCell.swift
//
//  Created by Rosalie Wessels on 17/02/2019.
//  Copyright © 2019 RosalieW. All rights reserved.
//

import UIKit

class CompetitionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var namePlace: UILabel!
    @IBOutlet weak var numberOfAssignmentsCompleted: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
