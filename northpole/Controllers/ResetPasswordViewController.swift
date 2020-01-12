//
//  ResetPasswordViewController.swift
//  northpole
//
//  Created by Yashodhan Kulkarni on 12/5/19.
//  Copyright © 2019 danielweatrowski. All rights reserved.
//

import UIKit
import Firebase

class ResetPasswordViewController: UIViewController {
    
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        bgView.layer.cornerRadius = 15
        emailView.layer.cornerRadius = 15
        sendButton.layer.cornerRadius = 15
        self.dismissKeyboard()
        // Do any additional setup after loading the view.
    }
    
    // Link is sent to email
    @IBAction func sendLinkPressed(_ sender: Any) {
        guard let email = emailTF.text else {
                    return
                }
                
                let alert = UIAlertController(title: "Password Reset", message: "Follow the link sent to your email.", preferredStyle: UIAlertController.Style.alert)
                
                
                let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                    UIAlertAction in
                    
                    Auth.auth().sendPasswordReset(withEmail: email) { (error) in
                        if let error = error {
                            print(error)
                        } else {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
                
                alert.addAction(okAction)

                self.present(alert, animated: true, completion: nil)
                
    }
    
    // Cancel button pressed
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
