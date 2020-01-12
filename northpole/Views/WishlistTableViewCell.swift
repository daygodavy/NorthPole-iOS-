//
//  WishlistTableViewCell.swift
//  northpole
//
//  Created by Daniel Weatrowski on 11/18/19.
//  Copyright © 2019 danielweatrowski. All rights reserved.
//

import UIKit

protocol WishListDelegate {
    func didPressLink(_ tag: Int )
}

class WishlistTableViewCell: UITableViewCell {
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var linkButton: UIButton!
    
    @IBOutlet var ratingDisplay: [UIImageView]!
    var delegate: WishListDelegate?
    
    @IBAction func linkButtonPressed(_ sender: UIButton) {
        delegate?.didPressLink(sender.tag)
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
