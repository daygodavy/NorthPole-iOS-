//
//  AddGifteeViewController.swift
//  FirebaseAuth
//
//  Created by Daniel Weatrowski on 12/5/19.
//

import UIKit
import Firebase

class AddGifteeViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var detailView: UILabel!
    var gifteeName: String = ""
    let rootRef = Database.database().reference(fromURL: "https://santa-f5457.firebaseio.com/")
    let user = Auth.auth().currentUser
    
    // MARK: - View Controls
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    // set up view properties
    func setUpView() {
        bgView.layer.cornerRadius = 15
        addButton.layer.cornerRadius = 15
        nameView.layer.cornerRadius = 15
        nameTF.becomeFirstResponder()
    }
    
    // MARK: - Actions
    // perform unwind segue to dismiss alert view
    @IBAction func goBackToRVC(_ sender: Any) {
        performSegue(withIdentifier: "unwindSegueToRVC", sender: self)
    }
    
    // prepare view for unwind segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if let recipientVC = segue.destination as? RecipientsViewController {
                if let gifteeName = nameTF.text {
                    recipientVC.newGifteeName = gifteeName
                }
            }
    }

    // dismiss view if user taps cancel button
    @IBAction func didTapCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
