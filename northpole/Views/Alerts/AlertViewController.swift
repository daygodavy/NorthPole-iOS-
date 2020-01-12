//
//  AlertViewController.swift
//  northpole
//
//  Created by Daniel Weatrowski on 12/4/19.
//  Copyright © 2019 danielweatrowski. All rights reserved.
//

import UIKit

class AlertViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var bgView: UIView!
    
    var alertTitle = String()
    var alertBody = String()
    var submitButtonTitle = String()
    var mainKeyboardType = UIKeyboardType(rawValue: 0)
    
    var buttonAction:  (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitButton.layer.cornerRadius = 15
        bgView.layer.cornerRadius = 15
        cancelButton.layer.cornerRadius = 15
        cancelButton.layer.borderColor = UIColor(named: "NPRed")?.cgColor
        setUpView()
    }
    
    func setUpView() {
        titleLabel.text = alertTitle
        detailLabel.text = alertBody
        submitButton.setTitle(submitButtonTitle, for: .normal )
    }
    
    // MARK: Actions
    @IBAction func didTapSubmit(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        buttonAction?()
    }
    @IBAction func didTapCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    


}
