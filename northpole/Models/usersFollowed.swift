

import Foundation
import UIKit


class usersFollowed {

    var fullName: String
    var phoneNumber: String
    var uid: String
    
    init() {
        self.fullName = ""
        self.phoneNumber = ""
        self.uid = ""
    }

    init(fullName: String, phoneNumber: String, uid: String) {

        self.fullName = fullName
        self.phoneNumber = phoneNumber
        self.uid = uid
        
    }



}
