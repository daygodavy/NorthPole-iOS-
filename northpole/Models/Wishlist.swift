//
//  Wishlist.swift
//  northpole
//
//  Created by Davy Chuon on 11/19/19.
//  Copyright © 2019 danielweatrowski. All rights reserved.
//

import Foundation

class WishlistGifts {
    var giftName: String
    var giftRank: Int
    var url: String
    var id : String
        
    init() {
        self.giftName = ""
        self.giftRank = 0
        self.url = ""
        self.id = ""
    }
    
    init(gift: String, rank: Int, url: String, id: String) {
        self.giftName = gift
        self.giftRank = rank
        self.url = url
        self.id  = id
    }
}
