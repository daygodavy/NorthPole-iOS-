//
//  validator.swift
//  northpole
//
//  Created by Daniel Weatrowski on 12/5/19.
//  Copyright © 2019 danielweatrowski. All rights reserved.
//

import Foundation

class Validate {
    // Usage:
    // define globally - let validator = Validate()
    // somewherre in the code - validator.validateKey(key: "string")
    // validate string contains no invalid Firebase char
    func validateKey(_ key: String) -> Bool {
        print("INSIDE VALIDATOR")
        if (key.contains("$") || key.contains(".") || key.contains("#") || key.contains("[") || key.contains("]") || key.contains("/")) {
            print("VALIDATOR SUCCESS")
            return false
        }
        print("VALIDATOR FAIL")
        return true
    }
    
    
}
