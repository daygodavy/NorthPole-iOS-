//
//  RecipientsViewController.swift
//  northpole
//
//  Created by Daniel Weatrowski on 11/7/19.
//  Copyright © 2019 danielweatrowski. All rights reserved.
//

import UIKit
import Firebase


class RecipientsViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var budgetView: UIView!
    @IBOutlet weak var addButton: UIButton!
    
    let rootRef = Database.database().reference(fromURL: "https://santa-f5457.firebaseio.com/")
    let user = Auth.auth().currentUser
    var userGiftees: [Giftee] = [] // temporary local storage
    var initLoadData: Bool = true
    var totalNumGiftees: Int = 0
    var newGifteeName: String = ""
    
    let maxHeaderHeight: CGFloat = 190
    let minHeaderHeight: CGFloat = 92
    // The last known scroll position
    var previousScrollOffset: CGFloat = 0

    // The last known height of the scroll view content
    var previousScrollViewHeight: CGFloat = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.addButton.layer.cornerRadius = self.addButton.frame.height / 2
        setGradientBackground()
        loadGiftees()
        hideKeyboardWhenTappedAround()

    }

    override func viewWillAppear(_ animated: Bool) {
        self.headerHeightConstraint.constant = self.maxHeaderHeight
        
        
        self.tableView.delegate = self
           self.tableView.dataSource = self
 
           self.addButton.layer.cornerRadius = self.addButton.frame.height / 2
           setGradientBackground()
           loadGiftees()
           hideKeyboardWhenTappedAround()
    }
    
    @IBAction func addGifteeButton(_ sender: Any) {
        let storyboard = UIStoryboard(name:"Main", bundle: .main)

        let alertVC = storyboard.instantiateViewController(identifier: "GifteeAlertVC") as! AddGifteeViewController

        present(alertVC, animated: true, completion: nil)
    }
    
    @IBAction func unwindToRecipientVC(segue:UIStoryboardSegue) {
 
        if newGifteeName.count == 0 {
        } else {
            self.prepNewGiftee(gifteeName: newGifteeName)
        }
    }
    
    
    func updateNumGiftees(count: Int) {
            if let uid = user?.uid {
                let users = self.rootRef.child("users")
                users.child(uid).child("gifteesCount").updateChildValues(["count": count])
            }
    }
    
    func getNumGifteesCount (completion: @escaping (Int, Error?) -> Void){
        if let uid = user?.uid {
                  let users = self.rootRef.child("users")
        
            users.child(uid).child("gifteesCount").observeSingleEvent(of: .value, with: { (snapshot) in

            let snap = snapshot.value as! [String: AnyObject]
            let count = snap["count"] as? Int
            let currentValue = count ?? 1000
                
            completion(currentValue, nil)

            })
        } // end if
    
    }
    
    
    
    func initNumGiftees() {
        if userGiftees.count > 0 {
            userGiftees.removeAll()
        }
        if let uid = user?.uid {
            let users = self.rootRef.child("users")
            users.child(uid).child("gifteesCount").updateChildValues(["count" : 0])
            users.child(uid).child("allGiftsCount").updateChildValues(["count" : 0])
            users.child(uid).child("totalSpending").updateChildValues(["count" : 0])
        }
        self.tableView.reloadData()
    }
    
    func prepNewGiftee(gifteeName: String) {
        let newGiftee = Giftee.init(name: gifteeName)
        self.userGiftees.append(newGiftee)
        self.storeNewGiftee()
        getNumGifteesCount() {count, error in
               if let error = error {
                   print(error)
                   return
               }
               let newCount = count + 1
               self.updateNumGiftees(count: newCount)
               
        }
        self.tableView.reloadData()
    }
    
    // stores user's new giftee into DB under unique ID
    func storeNewGiftee() {
        let target = userGiftees.last
        if let newGiftee = target?.fullName {
            if let uid = user?.uid {
                let users = self.rootRef.child("users")
                users.child(uid).child("giftee").updateChildValues([newGiftee : true])
            }
        }
    }
    
    func loadGiftees() {
        if let uid = user?.uid {
            rootRef.child("users").child(uid).child("giftee").observe(.value) { (snapshot) in
                if snapshot.hasChild("giftee") || snapshot.hasChildren() {
                    self.getExistingGiftees(snap: snapshot)
                    print("HAS CHILDREN")
                } else {
                    // new user, no giftees added yet
                    print("RESET SUCCESS")
                    self.initLoadData = false
                    self.initNumGiftees()
                }
            }
        }
    }
    
    func getExistingGiftees(snap: DataSnapshot) {
        let snapshotValue = snap.value as! Dictionary<String, AnyObject>
        let giftees = snapshotValue.keys
        if self.initLoadData {
            for gifteeName in giftees {
                let newGiftee = Giftee.init(name: gifteeName)
                self.loadGifteeDetails(giftee: newGiftee, name: gifteeName)
                self.userGiftees.append(newGiftee)
            }
        }
        self.initLoadData = false
        self.tableView.reloadData()
    }
    
    // reads/loads gifts from DB into table view
    func loadGifteeDetails(giftee: Giftee, name: String) {
        if let uid = user?.uid {
            rootRef.child("users").child(uid).child("giftee").child(name).child("giftsCount").observe(.value) { (snap) in
            
                if snap.hasChildren() {
                    self.getGifteeGiftsCount(snapshot: snap, giftee: giftee)
                }
            }
            rootRef.child("users").child(uid).child("giftee").child(name).child("giftsTotalCost").observe(.value) { (snap) in
                if snap.hasChildren() {
                    self.getGifteeTotCost(snapshot: snap, giftee: giftee)
                }
            }
        }
    }
    
    func getGifteeGiftsCount(snapshot: DataSnapshot, giftee: Giftee) {
        let snapCount = snapshot.value as! [String:Int]
        let countValue = snapCount["count"]
        if let totalAmnt = countValue {
            giftee.totalGifts = totalAmnt
            self.tableView.reloadData()
        }
    }
    
    func getGifteeTotCost(snapshot: DataSnapshot, giftee: Giftee) {
        let snapCost = snapshot.value as! [String:Double]
        let costValue = snapCost["cost"]
        if let totalCost = costValue {
            giftee.totalSpent = totalCost
            self.tableView.reloadData()
        }
    }
    
    func deleteGiftee(currGiftee: Giftee, gifteeIdx: Int) {
        self.userGiftees.remove(at: gifteeIdx)
        getNumGifteesCount() {count, error in
               if let error = error {
                   print(error)
                   return
               }
               let newCount = count - 1
               self.updateNumGiftees(count: newCount)
        }
        if let uid = user?.uid {
            let users = self.rootRef.child("users")
            users.child(uid).child("allGiftsCount").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChildren() {
                    let snapCount = snapshot.value as! [String:Int]
                    let totalGiftsCount = snapCount["count"]
                    if let newGiftsCount = totalGiftsCount {
                        print("currgiftees total gifts: \(currGiftee.totalGifts)")
                        print("total gifts count: \(newGiftsCount)")
                        users.child(uid).child("allGiftsCount").updateChildValues(["count": newGiftsCount - currGiftee.totalGifts])
                    }
                }
                
            })
                                
            users.child(uid).child("giftee").child("\(currGiftee.fullName)").child("giftsCount")
            users.child(uid).child("giftee").child("\(currGiftee.fullName)").removeAllObservers()
            users.child(uid).child("giftee").child("\(currGiftee.fullName)").child("gifts").removeAllObservers()
            users.child(uid).child("giftee").child("\(currGiftee.fullName)").removeValue()
        }
        loadGiftees()
    }
    
    func doubleToCurrency(val: Double) -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        // localize to your grouping and decimal separator
        currencyFormatter.locale = Locale.current

        // We'll force unwrap with the !, if you've got defined data you may need more error checking
        let priceString = currencyFormatter.string(from: NSNumber(value: val))!
        print(priceString) // Displays $9,999.99 in the US locale
        return (priceString)
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
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        guard let RecipientDetailVC = segue.destination as? RecipientDetailViewController,
            let idx = tableView.indexPathForSelectedRow?.row
            else {
                return
        }
        RecipientDetailVC.currGiftee = userGiftees[idx]
        RecipientDetailVC.gifteeName = userGiftees[idx].fullName
        // eventually pass the entire Giftee object
        
    }
    // MARK: - UI Controls
    

}

extension RecipientsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print("TABLEVIEW SIZE \(userGiftees.count)")
        if userGiftees.count == 0 {
            setEmptyView(title: "No giftees yet.", message: "Press '+' to add!", messageImage: UIImage(systemName: "multiply.circle.fill")!)
        }
        else {
            restore()
        }
        return userGiftees.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipientCell", for: indexPath) as! RecipientTableViewCell
        
        cell.bgView.layer.cornerRadius = 20.0
        cell.gifteeNameLabel.text = userGiftees[indexPath.row].fullName
        print(userGiftees[indexPath.row].fullName)

        cell.gifteeAmntSpentLabel.text = doubleToCurrency(val: userGiftees[indexPath.row].totalSpent)
        cell.gifteeNumGiftsLabel.text = "\(userGiftees[indexPath.row].totalGifts)"

        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {

            self.deleteGiftee(currGiftee: self.userGiftees[indexPath.row], gifteeIdx: indexPath.row)
            self.tableView.reloadData()
        }
    }
    
}
extension RecipientsViewController: UITableViewDelegate {

}

extension RecipientsViewController {
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
        titleLabel.text = title
        messageImageView.tintColor = UIColor(named: "NPRed")
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
