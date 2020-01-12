//
//  AddGiftViewController.swift
//  northpole
//
//  Created by Daniel Weatrowski on 12/5/19.
//  Copyright © 2019 danielweatrowski. All rights reserved.
//

import UIKit
import Firebase

class AddGiftViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var giftView: UIView!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var detailLabel: UILabel!
    
    @IBOutlet weak var giftTF: UITextField!
    @IBOutlet weak var priceTF: UITextField!
    var giftName: String = ""
    var giftPrice: String = ""
    var validator = Validate()
    let rootRef = Database.database().reference(fromURL: "https://santa-f5457.firebaseio.com/")
    let user = Auth.auth().currentUser
    
    // MARK: - View Controls

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    // set up view attributes
    func setUpView() {
        bgView.layer.cornerRadius = 15
        addButton.layer.cornerRadius = 15
        priceView.layer.cornerRadius = 15
        giftView.layer.cornerRadius = 15
        giftTF.becomeFirstResponder()
    }
    // perform unwind segue to dismiss controller
        @IBAction func goBackToRDVC(_ sender: Any) {
            performSegue(withIdentifier: "unwindSegueToRDVC", sender: self)
        }
        
        // prepare view for unwind back to detail vc
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if let recipientDVC = segue.destination as? RecipientDetailViewController {
                guard let name = giftTF.text else {return}
                if (!validator.validateKey(name) || name.isEmpty) {
                    recipientDVC.giftNameFlag = true
                    recipientDVC.newGiftName = name
                    dismiss(animated: true, completion: nil)
                } else {
                    if let giftName = giftTF.text, let giftPrice = priceTF.text {
                        recipientDVC.newGiftName = giftName
                        recipientDVC.newGiftPrice = giftPrice
                        recipientDVC.giftNameFlag = false
                    }
                }
            }

        }
    
    // dismiss view controller when user taps cancel button
    @IBAction func didTapCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
