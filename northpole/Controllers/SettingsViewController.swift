//
//  SettingsViewController.swift
//  northpole
//
//  Created by Daniel Weatrowski on 11/15/19.
//  Copyright © 2019 danielweatrowski. All rights reserved.
//

import UIKit
import Firebase

// Makes updates in homeview when you change something in settings
protocol SettingsDelegate {
    func makeUpdates()
}

class SettingsViewController: UIViewController {
    
    
    var delegate: SettingsDelegate?
    var alert = AlertManager()
    
    // MARK: - Properties

    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var firstNameView: UIView!
    @IBOutlet weak var lastNameView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var darkmodeView: UIView!
    @IBOutlet weak var resetPasswordView: UIView!
    @IBOutlet weak var resetView: UIView!
    @IBOutlet weak var phoneView: UIView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!


    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    var isEditingInfo = false
    
    
    // Name and email text fields
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneNumberTF: UITextField!
    
    @IBOutlet weak var changePWButton: UIView!
    @IBOutlet weak var logoutButton: UIView!
    @IBOutlet weak var resetButton: UIView!
    @IBOutlet weak var deleteFNButton: UIButton!
    @IBOutlet weak var deleteLNButton: UIButton!
    @IBOutlet weak var deleteEmailButton: UIButton!
    @IBOutlet weak var deletePhoneNumberButton: UIButton!
    
    
    // Firebase
    let rootRef = Database.database().reference(fromURL: "https://santa-f5457.firebaseio.com/")
    let user = Auth.auth().currentUser
    
    
    
    // MARK: - Actions
    @IBAction func didDeleteFirstName(_ sender: Any) {
        firstNameTF.text = ""
    }
    @IBAction func didDeleteLastName(_ sender: Any) {
        lastNameTF.text = ""
    }
    @IBAction func didDeleteEmail(_ sender: Any) {
        emailTF.text = ""
    }
    @IBAction func didDeletePhoneNumber(_ sender: Any) {
        phoneNumberTF.text = ""
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
   
    
    @IBAction func editButtonPressed(_ sender: Any) {
       
        if let editButtonState = editButton.title(for: .normal) {
                    if editButtonState == "Edit" {
                        editButton.setTitle("Save", for: .normal)
                        changePWButton.isHidden = true
                        logoutButton.isHidden = true
                        resetButton.isHidden = true
                        deleteFNButton.isHidden = false
                        deleteLNButton.isHidden = false
                        deleteEmailButton.isHidden = false
                        deletePhoneNumberButton.isHidden = false
                        phoneView.isHidden = true
                        
                        enableTextFields()
                        
                    } else if editButtonState == "Save" {
                        deleteFNButton.isHidden = true
                        deleteLNButton.isHidden = true
                        deleteEmailButton.isHidden = true
                        deletePhoneNumberButton.isHidden = true
                        changePWButton.isHidden = false
                        logoutButton.isHidden = false
                        resetButton.isHidden = false
                        phoneView.isHidden = false
                        editButton.setTitle("Edit", for: .normal)
                        disableTextFields()
                        
                        let fn = firstNameTF.text!
                        let ln = lastNameTF.text!
                        let email = emailTF.text!
                        let phoneNumber = phoneNumberTF.text!
                        saveInfoToFirebase(fn, ln, email, phoneNumber)
                        
                        updateUI()
                    }
        }
        
        
        imageView.alpha = 1.0
      
        
        
        //-- if the save button is pressed
        
        // save the first name and last name to firebase
        
        // Uncomment the next line
        // updateUI()
    }
    
    func enableTextFields() {
        firstNameTF.isUserInteractionEnabled = true
        lastNameTF.isUserInteractionEnabled = true
        emailTF.isUserInteractionEnabled = true
        phoneNumberTF.isUserInteractionEnabled = true
    }
    func disableTextFields() {
        firstNameTF.isUserInteractionEnabled = false
        lastNameTF.isUserInteractionEnabled = false
        emailTF.isUserInteractionEnabled = false
        phoneNumberTF.isUserInteractionEnabled = false
    }
    func saveInfoToFirebase(_ fn: String, _ ln: String, _ email: String, _ pn: String) {
                
        
        if let uid = user?.uid {
            let users = self.rootRef.child("users")
            
            users.child(uid).updateChildValues(["firstName" : fn])
            users.child(uid).updateChildValues(["lastName" : ln])
            users.child(uid).updateChildValues(["phoneNumber": pn])
            
        }
        
        
        
        // update email
        user?.updateEmail(to: email, completion: { (error) in
            if let _ = error {
                let alert = UIAlertController(title: "Error", message: "Invalid email. Please try again.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                let uid = Auth.auth().currentUser!.uid
                let thisUserRef = self.rootRef.child("users").child(uid)
                let thisUserEmailRef = thisUserRef.child("email")
                thisUserEmailRef.setValue(email)
                
            }
            
        })
        
    }
    
    
    @IBAction func changePasswordPressed(_ sender: Any) {
        
        guard let email = user?.email else {
            return
        }
        
//        var didReset = false
        let confirmAlert = alert.alert(title: "Reset Password?", body: "Proceed below", buttonTitle: "Reset") {
//            didReset = true
//            self.resetAlert()
            Auth.auth().sendPasswordReset(withEmail: email) { (error) in
                 if let error = error {
                     print(error)
                 } else {
                    print("resetAlert inside the else case")
                    self.resetAlert()
//                     self.logout()
                 }
             }
        }
        
        present(confirmAlert, animated: true)
        
    }
    
    func resetAlert() {
//        if (didReset) {
        print("reaching the resetAlert function")
        let resetConfirmedAlert = alert.alert(title: "Password Reset", body: "A verification link has been sent to your email", buttonTitle: "OK") {
            print("now logging out")
            self.logout()
        }
        present(resetConfirmedAlert, animated: true)
//        }
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        let logoutAlert = alert.alert(title: "Logout?", body: "Proceed below", buttonTitle: "Logout") {
            self.logout()
        }
        present(logoutAlert, animated: true)
    }
    
    func logout() {
        // Segue back to login screen
        if let uid = user?.uid {
            let users = self.rootRef.child("users")
            users.child(uid).child("isLoggedIn").updateChildValues(["isLoggedIn" : false])
        }
        do {
            try Auth.auth().signOut()
        }
        catch {
            print("ERROR ON AUTH SIGNOUT")
        }
        self.performSegue(withIdentifier: "goToLoginScreen", sender: self)

        
    }
    
   
    @IBAction func resetDataPressed(_ sender: Any) {
        // Ask for password
        // Reset firebase
        let resetAlert = alert.alert(title: "Delete all data?", body: "All data will be removed", buttonTitle: "Delete") {
            if let uid = self.user?.uid {
                let users = self.rootRef.child("users")

                users.child(uid).child("giftee").removeValue {error,arg  in
                    if error != nil {
                        print("error \(error!)")
                    }
                }
                users.child(uid).child("totalSpending").removeValue()
                users.child(uid).child("allGiftsCount").removeValue()
                users.child(uid).child("gifteesCount").removeValue()
                users.child(uid).child("wishlist").removeValue()

            }
            self.dismiss(animated: true, completion: nil)
        }
        present(resetAlert, animated: true)

    }
    
    
    
    
    // MARK: - View Controls
    override func viewDidLoad() {
        super.viewDidLoad()

        self.scrollView.delegate = self
        setGradientBackground()
        self.resetView.layer.cornerRadius = 20.0
        self.firstNameView.layer.cornerRadius = 20.0
        self.lastNameView.layer.cornerRadius = 20.0
        self.emailView.layer.cornerRadius = 20.0
        self.darkmodeView.layer.cornerRadius = 20.0
        self.resetPasswordView.layer.cornerRadius = 20.0
        self.phoneView.layer.cornerRadius = 20.0
    
        hideKeyboardWhenTappedAround()
        disableTextFields()
        updateUI()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.imageView.alpha = 1.0
        updateUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.delegate?.makeUpdates()
    }
    
    
    // Updates UI
    func updateUI() {
        deleteFNButton.isHidden = true
        deleteLNButton.isHidden = true
        deleteEmailButton.isHidden = true
        deletePhoneNumberButton.isHidden = true
        if let email = Auth.auth().currentUser?.email {
            userEmailLabel.text = email
            emailTF.text = email
        }
        
        
        if let uid = user?.uid {
                            let users = self.rootRef.child("users")
                  
                      users.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in

                      let snap = snapshot.value as! [String: AnyObject]
                        
                        let firstName = (snap["firstName"] as? String) ?? "North"
                        
                        let lastName = (snap["lastName"] as? String) ?? "Pole"
                        
                        let phoneNumber = (snap["phoneNumber"] as? String) ?? "(999) 999-9999"
                   
                        self.userNameLabel.text = firstName
                        self.firstNameTF.text = firstName
                        self.lastNameTF.text = lastName
                        self.phoneNumberTF.text = phoneNumber
                        
                      })
                  } // end if
        
        
    }
    
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

    
    func setGradientBackground() {
        let colorTop = UIColor.white.cgColor
        let colorBottom = UIColor(red:0.92, green:0.93, blue:0.96, alpha:1.0).cgColor

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds

        self.view.layer.insertSublayer(gradientLayer, at:0)
    }
    

}



extension SettingsViewController: UIScrollViewDelegate {
    // MARK: - UI Code, don't touch
 
}
