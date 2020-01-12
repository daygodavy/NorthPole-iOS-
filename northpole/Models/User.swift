//
//  User.swift
//  
//
//  Created by viv on 12/4/19.
//

import Foundation


class loggedUser {
    var firstName: String
    var lastName: String
    var phoneNumber: String
    var uid: String
    

    init() {
        self.firstName = ""
        self.lastName = ""
        self.phoneNumber = ""
        self.uid = ""
    }

    init(firstName: String, lastName: String, phoneNumber: String, uid: String) {

        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.uid = uid
        
    }

}
