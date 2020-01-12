//
//  OtherUserWishlistTableViewCell.swift
//  northpole
//
//  Created by Davy Chuon on 12/3/19.
//  Copyright © 2019 danielweatrowski. All rights reserved.
//

import UIKit
protocol OtherUserWishlistDelegate {
    func didPressLink(_ tag: Int )
}
class OtherUserWishlistTableViewCell: UITableViewCell {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var linkButton: UIButton!
    
    @IBOutlet var ratingDisplay: [UIImageView]!
    var delegate: OtherUserWishlistDelegate?
    
    @IBAction func didPressLink(_ sender: UIButton) {
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
