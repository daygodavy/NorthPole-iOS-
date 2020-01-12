//
//  SignInViewController.swift
//  northpole
//
//  Created by viv on 11/11/19.
//  Copyright © 2019 danielweatrowski. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Properties

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    
        
    @IBOutlet weak var usernameInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
    var newUser: Bool = false
    var autoLogin: Bool = false
    var signIn = true
    var spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    let ref = Database.database().reference(fromURL: "https://santa-f5457.firebaseio.com/")
    let user = Auth.auth().currentUser

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createNewAccount" {
            let vc : SignUpViewController = segue.destination as! SignUpViewController
            vc.ref  = ref
            vc.user = user
            vc.newUser = newUser
        }
    }
    
    func setUpView(){ // set up ui
     emailView.layer.cornerRadius = 15
     passwordView.layer.cornerRadius = 15
     loginButton.layer.cornerRadius = 15
     bgView.layer.cornerRadius = 15

    }

    func switchLoadView() {
        view = UIView()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    
    func errorAlert(title: String, error: String, dismissCurentView: Bool) {
        
        let alert = UIAlertController(title: title, message: error, preferredStyle: .alert)
        
        if dismissCurentView == true {
            
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil ))
            alert.addAction(UIAlertAction(title: "Resend Verification", style: .cancel, handler: {(alert) -> Void in
                print("gets to reset email")
                Auth.auth().currentUser?.reload()
                Auth.auth().currentUser?.sendEmailVerification()
               } ))
            
        }else{
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil ))
        }
        self.present(alert, animated: true)
        
        
    }
    
    func isValidEmail(emailStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: emailStr)
    }
    
    func allFieldsEntered(password: String, email: String) -> Bool {
        
        if (password.isEmpty || email.isEmpty) {
            
            return false
        } else{ return true }
        
    }
    
    func signIn(withEmail: String, password: String){
        
        Auth.auth().signIn(withEmail: withEmail, password: password) { [weak self] authResult, error in
                     guard self != nil else { return }
                     if let error = error{
                         print("Error signing in")
                        self?.errorAlert(title: "Error signing in", error: error.localizedDescription, dismissCurentView: false)
                         print(error)
                     }
                     else{ // do not let user enter app until they've verified their email address
                        if (Auth.auth().currentUser?.isEmailVerified == false){
                            self?.errorAlert(title: "Email not verified", error: "Please verify email before continuing", dismissCurentView: true)
                            return
                        }
                        else{
                         self?.performSegue(withIdentifier: "autoLogin", sender: nil)
                        }
                     }
                 } // auth sign in
    }
    
    
    @IBAction func signInUser(_ sender: Any) {
            rememberUser()
            if let email = usernameInput.text, let password = passwordInput.text{
            
            let fieldsEntered = allFieldsEntered(password: password, email: email)
                    
            let emailFormatValidated = isValidEmail(emailStr: email)
                
            if fieldsEntered && emailFormatValidated{
                
                signIn(withEmail: email, password: password)
                
            }else{
                if !fieldsEntered {errorAlert(title: "Enter all fields", error: "Missing one or more required fields", dismissCurentView: true)}
                if !emailFormatValidated { errorAlert(title: "Check email entered", error: "Email format is invalid", dismissCurentView: false)}
            }
         }
    }
    
    func rememberUser() {
        if let uid = user?.uid {
            let users = self.ref.child("users")
            users.child(uid).child("isLoggedIn").updateChildValues(["isLoggedIn" : true])
        }
    }
        
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
     let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
