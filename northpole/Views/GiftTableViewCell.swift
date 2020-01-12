//
//  GiftTableViewCell.swift
//  northpole
//
//  Created by Daniel Weatrowski on 11/7/19.
//  Copyright © 2019 danielweatrowski. All rights reserved.
//

import UIKit

class GiftTableViewCell: UITableViewCell {
    // MARK: - Properties
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
