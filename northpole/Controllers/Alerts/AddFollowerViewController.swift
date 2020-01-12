//
//  AddFollowerViewController.swift
//  northpole
//
//  Created by Daniel Weatrowski on 12/5/19.
//  Copyright © 2019 danielweatrowski. All rights reserved.
//

import UIKit
import Firebase

class AddFollowerViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var mainTF: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var textBgView: UIView!
    
    var alertTitle = String()
    var alertBody = String()
    var submitButtonTitle = String()
    var mainKeyboardType = UIKeyboardType(rawValue: 0)
    
    var buttonAction:  (() -> Void)?
    var inputPhoneNumber: String = ""
    let rootRef = Database.database().reference(fromURL: "https://santa-f5457.firebaseio.com/")
    let user = Auth.auth().currentUser
    
    // MARK: - View Controls
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    // set up view properties
    func setUpView() {
        submitButton.layer.cornerRadius = 15
        bgView.layer.cornerRadius = 15
        textBgView.layer.cornerRadius = 15
        cancelButton.layer.cornerRadius = 15
        mainTF.becomeFirstResponder()
    }
    
    // MARK: Actions
    // perform unwind segue to remove alert
        @IBAction func goBackToUFVC(_ sender: Any) {
            performSegue(withIdentifier: "unwindSegueToUFVC", sender: self)
        }
        
    
    // prepare for unwind segue
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                if let UserFollowingsVC = segue.destination as? UserFollowingsViewController {
                    if let inputPhoneNumber = mainTF.text {
                        UserFollowingsVC.otherUserPhoneNum = inputPhoneNumber
                    }
                }
        }
    
    // dismiss view if user taps cancel
    @IBAction func didTapCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
