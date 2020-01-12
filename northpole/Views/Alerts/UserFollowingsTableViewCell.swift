//
//  UserFollowingsTableViewCell.swift
//  northpole
//
//  Created by Davy Chuon on 12/4/19.
//  Copyright © 2019 danielweatrowski. All rights reserved.
//

import Foundation
import UIKit

class UserFollowingsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var wisheeNameLabel: UILabel!
    @IBOutlet weak var wisheeItemCountLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
