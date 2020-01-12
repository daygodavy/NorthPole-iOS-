//
//  RecipientTableViewCell.swift
//  northpole
//
//  Created by Daniel Weatrowski on 11/7/19.
//  Copyright © 2019 danielweatrowski. All rights reserved.
//

import UIKit

class RecipientTableViewCell: UITableViewCell {
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var gifteeNameLabel: UILabel!
    @IBOutlet weak var gifteeAmntSpentLabel: UILabel!
    @IBOutlet weak var gifteeNumGiftsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
