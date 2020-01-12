//
//  AlertManager.swift
//  northpole
//
//  Created by Daniel Weatrowski on 12/4/19.
//  Copyright © 2019 danielweatrowski. All rights reserved.
//

import Foundation
import UIKit

class AlertManager {
    
    func alert(title: String, body: String, buttonTitle: String, completion: @escaping () -> Void) -> AlertViewController {
        let storyboard = UIStoryboard(name:"Alert", bundle: .main)
        
        let alertVC = storyboard.instantiateViewController(identifier: "AlertVC") as! AlertViewController
    
        alertVC.alertTitle = title
        alertVC.alertBody = body
        alertVC.submitButtonTitle = buttonTitle
        alertVC.buttonAction = completion
        
        return alertVC 
    }
    
    
    
}
