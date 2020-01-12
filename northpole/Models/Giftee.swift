//
//  Giftee.swift
//  northpole
//
//  Created by Davy Chuon on 11/14/19.
//  Copyright © 2019 danielweatrowski. All rights reserved.
//

import Foundation

class Giftee {
    var fullName: String
    var totalSpent: Double
    var giftsPurchased: [Gifts]
    var totalGifts: Int

    init() {
        self.fullName = ""
        self.totalSpent = 0.0
        self.giftsPurchased = [Gifts]()
        self.totalGifts = 0
    }

    init(name: String) {
        self.fullName = name
        self.totalSpent = 0.0
        self.giftsPurchased = [Gifts]()
        self.totalGifts = 0
    }

    class Gifts {
        var giftName: String
        var giftPrice: Double
        
        init() {
            self.giftName = ""
            self.giftPrice = 0.0
        }
        
        init(gift: String, price: Double) {
            self.giftName = gift
            self.giftPrice = price
        }
    }


}
