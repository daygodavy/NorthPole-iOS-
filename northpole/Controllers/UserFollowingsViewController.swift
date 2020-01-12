  
//
//  UserFollowingsViewController.swift
//  northpole
//
//  Created by Davy Chuon on 12/3/19.
//  Copyright © 2019 danielweatrowski. All rights reserved.
//

import UIKit
import Firebase

class UserFollowingsViewController: UIViewController, OuvlwDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var followedWisheeSearchBar: UISearchBar!
    @IBOutlet weak var searchNewWisheeButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBarHeightConstraint: NSLayoutConstraint!
    var resultSearchController = UISearchController()
    let rootRef = Database.database().reference(fromURL: "https://santa-f5457.firebaseio.com/")
    let user = Auth.auth().currentUser
    var rank: String?
    var url: String?
    var itemName: String?
    var initLoadData: Bool = true
    let alertManager = AlertManager()
    var wisheesList: [usersFollowed] = []
    var filteredWisheesList: [usersFollowed] = []
    var isSearching: Bool = false
    var otherUserPhoneNum: String = ""
    
    
    override func viewWillAppear(_ animated: Bool) {
        loadWisheesList()
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        searchBarHeightConstraint.constant = 0
        self.followedWisheeSearchBar.delegate = self
        self.searchButton.layer.cornerRadius = searchButton.frame.width / 2
        self.searchNewWisheeButton.layer.cornerRadius = searchNewWisheeButton.frame.width / 2
        followedWisheeSearchBar.returnKeyType = UIReturnKeyType.done
        searchBar.searchBarStyle = .minimal
        setGradientBackground()
        hideKeyboardWhenTappedAround()
        loadWisheesList()
    }
    
    func showSearchBar() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 5, animations: {
            self.searchBarHeightConstraint.constant = 44
        })
    }
    
    func loadWisheesList() {
         if let uid = user?.uid {
             rootRef.child("users").child(uid).child("usersFollowed").observe(.value) { (snapshot) in
                 if snapshot.hasChildren() { self.getExistingWishees(snap: snapshot) }
                 else { self.initLoadData = false }
             } //load children if the exist, else dont load
         } // end if
     }
        
    func getExistingWishees(snap: DataSnapshot) {
        
            if self.initLoadData {
                for child in snap.children { // for each child in list of children
                    guard let takeSnapshot = child as? DataSnapshot else{ // make sure snapshot exists
                        return
                    }
                    guard let value = takeSnapshot.value as? [String: AnyObject] else{ // make sure value exists
                        return
                    }
                    // make sure values needed exist
                    guard let wisheeName = value["Name"] as? String, let wisheePhoneNum = value["phoneNumber"] as? String, let wisheeId = value["UID"] as? String else{
                        print("Error getting wishee")
                        return
                    }
                    // store data retrieved from firebase into our local list
                    let newWishee = usersFollowed.init(fullName: wisheeName, phoneNumber: wisheePhoneNum, uid: wisheeId)
                    self.wisheesList.append(newWishee)
                    
                }
                self.initLoadData = false
            self.tableView.reloadData()
        }
    }

    
    @IBAction func searchTest(_ sender: Any) {

        showSearchBar()
        searchBar.becomeFirstResponder()
        
    }
        
    @IBAction func searchNewUserButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name:"Main", bundle: .main)

        let alertVC = storyboard.instantiateViewController(identifier: "AlertVC") as! AddFollowerViewController
        present(alertVC, animated: true, completion: nil)
    }

    @IBAction func unwindToUserFollowingsVC(segue:UIStoryboardSegue) {
        let users = self.rootRef.child("users")
        let query = users.queryOrdered(byChild: "phoneNumber").queryEqual(toValue: otherUserPhoneNum)
        query.observeSingleEvent(of: .value, with: { snapshot in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let dict = snap.value as! [String: Any]
                let phoneNum = dict["phoneNumber"] as! String
                let uid = dict["UID"] as! String
                let firstName = dict["firstName"] as! String
                let lastName = dict["lastName"] as! String
                if phoneNum == self.otherUserPhoneNum {
                    self.segueToUserWL(userId: uid, fn: firstName, ln: lastName, userNum: phoneNum)
                }
            }
        })
    }
    
    
    func segueToUserWL(userId: String, fn: String, ln: String, userNum: String) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let otherWLVC = storyboard.instantiateViewController(identifier: "OtherUserWishListViewController")
            // force unwrap justification: successful submission should
            // only result in showing the code verification screen
            let otherUserWLVC = otherWLVC as! OtherUserWishListViewController
            // define phone number variable to be passed to next view
            // verifyCode.phoneNumber = formattedPhoneNumber
            // send other user's UID to next view
            otherUserWLVC.currUserId = userId
            otherUserWLVC.currUserFN = fn
            otherUserWLVC.currUserLN = ln
            otherUserWLVC.currUserPhoneNum = userNum
            otherUserWLVC.delegate = self
            self.present(otherUserWLVC, animated: true, completion: nil)
    }
    
    func makeChanges(followStatus: Bool, uid: String, fullName: String, phoneNum: String) {
        isSearching = false
        followedWisheeSearchBar.text = ""
        getWisheesList()
        tableView.reloadData()
    }
    
    func getWisheesList() {
         if let uid = user?.uid {
             rootRef.child("users").child(uid).child("usersFollowed").observe(.value) { (snapshot) in
                 if snapshot.hasChildren() {
                    self.wisheesList.removeAll()
                    self.updateWishees(snap: snapshot)
                 } else {
                    self.wisheesList = []
                    self.tableView.reloadData()
                }
             }
         }
     }
        
    func updateWishees(snap: DataSnapshot) {
        
                for child in snap.children { // for each child in list of children
                    guard let takeSnapshot = child as? DataSnapshot else{ // make sure snapshot exists
                        return
                    }
                    guard let value = takeSnapshot.value as? [String: AnyObject] else{ // make sure value exists
                        return
                    }
                    // make sure values needed exist
                    guard let wisheeName = value["Name"] as? String, let wisheePhoneNum = value["phoneNumber"] as? String, let wisheeId = value["UID"] as? String else{
                        print("Error getting wishee")
                        return
                    }
                    // store data retrieved from firebase into our local list
                    let newWishee = usersFollowed.init(fullName: wisheeName, phoneNumber: wisheePhoneNum, uid: wisheeId)
                    self.wisheesList.append(newWishee)
                }
            self.tableView.reloadData()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        guard let OuvlwVC = segue.destination as? OtherUserWishListViewController,
            let idx = tableView.indexPathForSelectedRow?.row
            else {
                return
        }
        OuvlwVC.delegate = self
        OuvlwVC.currUserFN = ""
        if isSearching {
            OuvlwVC.currUserLN = filteredWisheesList[idx].fullName
            OuvlwVC.currUserPhoneNum = filteredWisheesList[idx].phoneNumber
            OuvlwVC.currUserId = filteredWisheesList[idx].uid
        } else {
            OuvlwVC.currUserLN = wisheesList[idx].fullName
            OuvlwVC.currUserPhoneNum = wisheesList[idx].phoneNumber
            OuvlwVC.currUserId = wisheesList[idx].uid
        }
    }
}



extension UserFollowingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            if filteredWisheesList.count == 0 {
                setEmptyView(title: "No wishees found!", message: "Try adding their phone number.", messageImage: UIImage(systemName: "exclamationmark.circle.fill")!)

            } else {
                restore()
            }
            return filteredWisheesList.count
        }
        if wisheesList.count == 0 {
            setEmptyView(title: "You're not following anyone.", message: "Add a wishee to start!", messageImage: UIImage(systemName: "exclamationmark.circle.fill")!)
        }
        else {
            restore()
        }
        return wisheesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserFollowingsCell", for: indexPath) as! UserFollowingsTableViewCell
        cell.bgView.layer.cornerRadius = 20.0

        
        if isSearching {
            cell.wisheeNameLabel.text = filteredWisheesList[indexPath.row].fullName
        } else {
            cell.wisheeNameLabel.text = wisheesList[indexPath.row].fullName
        }
        
        return cell
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if followedWisheeSearchBar.text == nil || followedWisheeSearchBar.text == "" {
            isSearching = false
            view.endEditing(true)
            tableView.reloadData()
        } else {
            isSearching = true
            filteredWisheesList = wisheesList.filter({$0.fullName.lowercased().contains(followedWisheeSearchBar.text!.lowercased())})
            tableView.reloadData()
        }
    }
}

extension UserFollowingsViewController: UITableViewDelegate {
    func setEmptyView(title: String, message: String, messageImage: UIImage) {
        
        let emptyView = UIView(frame: CGRect(x: tableView.center.x, y: tableView.center.y, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        
        let messageImageView = UIImageView()
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        
        messageImageView.backgroundColor = .clear
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageImageView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont(name: "Avenir-Heavy", size: 18)
        
        messageLabel.textColor = UIColor.lightGray
        messageLabel.font = UIFont(name: "Avenir-Medium", size: 17)
        
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageImageView)
        emptyView.addSubview(messageLabel)
        
        messageImageView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        messageImageView.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor, constant: -20).isActive = true
        messageImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        messageImageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: messageImageView.bottomAnchor, constant: 10).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        messageLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        
        messageImageView.image = messageImage
        messageImageView.tintColor = UIColor(named: "NPRed")
        titleLabel.text = title
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        
        UIView.animate(withDuration: 1, animations: {
            
            messageImageView.transform = CGAffineTransform(rotationAngle: .pi / 10)
        }, completion: { (finish) in
            UIView.animate(withDuration: 1, animations: {
                messageImageView.transform = CGAffineTransform(rotationAngle: -1 * (.pi / 10))
            }, completion: { (finishh) in
                UIView.animate(withDuration: 1, animations: {
                    messageImageView.transform = CGAffineTransform.identity
                })
            })
            
        })
        
        tableView.backgroundView = emptyView
        tableView.separatorStyle = .none
    }
    
    func restore() {
        
        tableView.backgroundView = nil
        tableView.separatorStyle = .none
        
    }
    
}
