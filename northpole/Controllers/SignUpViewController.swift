//
//  SignUpViewController.swift
//  northpole
//
//  Created by viv on 12/4/19.
//  Copyright © 2019 danielweatrowski. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import PhoneNumberKit

class SignUpViewController: UIViewController {// class

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        
        
        self.hideKeyboardWhenTappedAround()

        // Do any additional setup after loading the view.
    }
    
    let phoneNumberKit = PhoneNumberKit()

    @IBOutlet weak var phoneNumber: PhoneNumberTextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var emailVie: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var confirmView: UIView!
    @IBOutlet weak var createButton: UIButton!
    
    
    
    var ref : DatabaseReference?
    var user : User?
    var newUser: Bool?
    
    func setUpView() {
        emailVie.layer.cornerRadius = 15
        passwordView.layer.cornerRadius = 15
        createButton.layer.cornerRadius = 15
        bgView.layer.cornerRadius = 15
        confirmView.layer.cornerRadius = 15
        phoneView.layer.cornerRadius = 15
        
        //allow for flag
        phoneNumber.withFlag = true
        phoneNumber.withExamplePlaceholder = true
        
    }

    func errorAlert(title: String, error: String, dismissCurentView: Bool) {
        
        let alert = UIAlertController(title: title, message: error, preferredStyle: .alert)
        
        if dismissCurentView == true {
            
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: {(alert) -> Void in
                self.dismiss(animated: true)
                   } ))
            
        }else{
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil ))
        }
        self.present(alert, animated: true)
        
        
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true)
        
    }
    
    func isValidEmail(emailStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: emailStr)
    }
    
    func allFieldsEntered(newPassword: String, newConfirmPassword: String, newEmail: String, newPhoneNumber: String ) -> Bool {
        
        if (newPassword.isEmpty || newConfirmPassword.isEmpty || newEmail.isEmpty || newPhoneNumber.isEmpty) {
            
            return false
        } else{ return true }
        
    }
    func passwordsMatch(newPassword: String, newConfirmPassword: String) -> Bool{
        
        if ( newConfirmPassword == newPassword){ return true } else { return false}
        
        
    }
    
    func createUser(withEmail: String, password: String, newPhone: String){
        
       Auth.auth().createUser(withEmail: withEmail, password: password) { authResult, error in // authentication
            if let error = error {//err
                
                self.errorAlert(title: "Error Creating User", error: error.localizedDescription, dismissCurentView: false)
                print(error)
            }//err
            else{//no err
                
                
                Auth.auth().currentUser?.sendEmailVerification()
                let user = Auth.auth().currentUser
                guard let uid = user?.uid else { return }
                // add user infor to db
                if let newPhone = self.phoneNumber.text, let newEmail = self.email.text{
                    let users = self.ref?.child("users")
                    let phoneNumberKey = ["phoneNumber": newPhone]
                    let emailNumberKey = ["email": newEmail]
                    let userID = ["UID" : uid]
                    users?.child(uid).updateChildValues(phoneNumberKey)
                    users?.child(uid).updateChildValues(userID)
                    users?.child(uid).updateChildValues(emailNumberKey)
                    // default until fullname VC added for deploy
                    users?.child(uid).updateChildValues(["firstName" : "North"])
                    users?.child(uid).updateChildValues(["lastName" : "Pole"])
                }

            }// no err
        }
        
    }
    
    func callCreate(newPhoneNumber: String, newEmail: String, newPassword: String, fieldsEntered: Bool, emailFormatValidated: Bool, passwordsVerified: Bool){
        
        // info info is valided, creaet user account else return error message
         if fieldsEntered && emailFormatValidated && passwordsVerified{

                self.createUser(withEmail: newEmail, password: newPassword, newPhone: newPhoneNumber)
                self.errorAlert(title: "Please confirm email",error: "Please confirm email link before you sign in with new credentials", dismissCurentView: true)
          } else{
                   if !fieldsEntered{ self.errorAlert(title: "Enter all fields",error: "Missing one or more required text fields", dismissCurentView: false) }
                    else if !passwordsVerified { self.errorAlert(title: "Password Error", error: "Passwords do not match", dismissCurentView: false) }
                    else if !emailFormatValidated { self.errorAlert(title: "Check email entered", error: "Email format is invalid", dismissCurentView: false) }

            }// else
        
    } // end call create
    
    
    @IBAction func createAccount(_ sender: Any) { // ibaction
        // vlaidate fields
        if let newPassword = password.text, let newEmail = email.text, let newConfirmPassword = confirmPassword.text, let newPhoneNumber = phoneNumber.text{
            
            // ensure fields are formatted correctly
            let fieldsEntered = allFieldsEntered(newPassword: newPassword, newConfirmPassword: newConfirmPassword, newEmail: newEmail, newPhoneNumber: newPhoneNumber)
            
            let emailFormatValidated = isValidEmail(emailStr: newEmail)
            
            let passwordsVerified = passwordsMatch(newPassword: newPassword, newConfirmPassword: newConfirmPassword)
            
    
            self.callCreate(newPhoneNumber: newPhoneNumber, newEmail: newEmail, newPassword: newPassword, fieldsEntered: fieldsEntered, emailFormatValidated: emailFormatValidated, passwordsVerified: passwordsVerified)
                
            } // end closure
    }// ibaction createAccount
}// class


