//
//  WishlistViewController.swift
//  northpole
//
//  Created by Daniel Weatrowski on 11/21/19.
//  Copyright © 2019 danielweatrowski. All rights reserved.
//

import UIKit
import Firebase

class WishlistViewController: UIViewController, WishListAddItem, WishListDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let rootRef = Database.database().reference(fromURL: "https://santa-f5457.firebaseio.com/")
    let user = Auth.auth().currentUser
    var wishlistItems: [WishlistGifts] = []
    var rank: String?
    var url: String?
    var ret = false
    var itemName: String?
    var dic = [String:Int]()
    var initLoadData: Bool = true
    var obj: WishlistGifts?
    var userName: String = "Username" // change
    var currEditItemIdx: Int = -1
    var wishlist: String = ""
    var userPhoneNum: String = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.addButton.layer.cornerRadius = self.addButton.frame.height / 2
        self.shareButton.layer.cornerRadius = self.shareButton.frame.height / 2
        self.checkWishlistExists()
        setGradientBackground()
        loadItems()
    }
    
    @IBAction func didSelectShare(_ sender: Any) {
        shareItems()
    }
    
    func itemAdded(itemField: String?, URLField: String?, rank: Int?, editStatus: Bool?, id: String?) {
        if let item = itemField, let url = URLField, let rank = rank, let edit = editStatus, let currItemId = id{
            if edit {
                self.editCurrItem(name: item, url: url, rank: rank, id: currItemId)
            }
            else {
                self.prepNewItem(name: item, url: url, rank: rank)
            }
        }
    }
    
    func editCurrItem(name: String, url: String, rank: Int, id: String) {
        if currEditItemIdx >= 0 {
            wishlistItems[currEditItemIdx].giftName = name
            wishlistItems[currEditItemIdx].giftRank = rank
            wishlistItems[currEditItemIdx].url = url
            self.tableView.reloadData()
        }
        if let uid = user?.uid {
            let users = self.rootRef.child("users")
            let wishlistItem = users.child(uid).child("wishlist").child(id)
            wishlistItem.updateChildValues(["giftName":name])
            wishlistItem.updateChildValues(["giftRank":rank])
            wishlistItem.updateChildValues(["url":url])
        }
    }
    
    func prepNewItem(name: String, url: String, rank: Int) {
        // store new item added in object
        obj = WishlistGifts.init(gift: name, rank: rank, url: url, id: "")
        guard let item = obj else{
            return
        }
        // if item exists, append it to our list of items and store
        self.wishlistItems.append(item)
        self.storeNewItem()
    }
    
    func storeNewItem() {
        
        if let uid = user?.uid {
                let users = self.rootRef.child("users")
                guard let item = obj else{
                    return
                }
                //assign unique id to each new gift
                let newGift = users.child(uid).child("wishlist").childByAutoId()
                obj?.id = newGift.key!
                // store values of the wishlist gift, unique id is also stored as a child to access later
                newGift.updateChildValues(["giftName": item.giftName])
                newGift.updateChildValues(["giftRank": item.giftRank])
                newGift.updateChildValues(["giftID": obj?.id ?? "erroridnotentered"])
                newGift.updateChildValues(["url": item.url])
                self.tableView.reloadData()
        }
    }
    
    func loadItems() {
         if let uid = user?.uid {
             rootRef.child("users").child(uid).child("wishlist").observe(.value) { (snapshot) in
                 if snapshot.hasChildren() { self.getExistingItems(snap: snapshot) }
                 else { self.initLoadData = false }
             } //load children if the exist, else dont load
         } // end if
     }
    
    func getExistingItems(snap: DataSnapshot) {
        
        if self.initLoadData {
            for child in snap.children{ // for each child in list of children
                guard let takeSnapshot = child as? DataSnapshot else{ // make sure snapshot exists
                    return
                }
                guard let value = takeSnapshot.value as? [String: AnyObject] else{ // make sure value exists
                    return
                }
                // make sure values needed exist
                guard let giftName = value["giftName"] as? String, let giftRank = value["giftRank"] as? Int, let giftURL = value["url"] as? String, let giftID = value["giftID"] as? String else{
                    // Error getting giftname, giftRank, or url from value
                    return
                }
                // store data retrieved from firebase into our local list
                let newItem = WishlistGifts.init(gift: giftName, rank: giftRank, url: giftURL, id: giftID)
                self.wishlistItems.append(newItem)
            }
            
            self.initLoadData = false
            self.tableView.reloadData()
        }
    }
    
    func shareItems() {
        if let uid = user?.uid {
            self.rootRef.child("users").child(uid).observeSingleEvent(of: .value) {
                (snapshot) in
                if snapshot.exists() && snapshot.value != nil {
                    if let snap = snapshot.value as? [String:Any] {
                        self.userName = snap["firstName"] as! String
                        self.sendWishlistText(name: self.userName)
                    }
                }
            }
        }
    }
    
    func sendWishlistText(name: String) {
                self.wishlist = "\(name)'s 2019 Wishlist\n\n"
                let greeting = "NorthPole App - 2019\n🤶🏻📜🎅🏻"
                for item in wishlistItems {
                    let bulletPoint: String = "\u{2022}"
                    let itemString: String = "\(bulletPoint) \(item.giftName)\n"
                    var url: String = "\(item.url)"
                    if (item.url != "") {
                        url += "\n"
                    }
                    var stars = "Desire Rating: "
                    stars += "\(item.giftRank)/5"
                    stars += "\n\n"
                    
                    
                    self.wishlist += itemString + url + stars
                }
                self.wishlist += "\n\(greeting)"
                let activityViewController = UIActivityViewController(activityItems: [ wishlist ], applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
                // exclude some activity types from the list (optional)
                activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]

                // present the view controller
                self.present(activityViewController, animated: true, completion: nil)
    }
    
    func deleteItem(currItem: WishlistGifts, itemIdx: Int) {
        
        self.wishlistItems.remove(at: itemIdx)
        if let uid = user?.uid {
            let users = self.rootRef.child("users")
            users.child(uid).child("wishlist").child(currItem.id).removeAllObservers()
            users.child(uid).child("wishlist").child(currItem.id).removeValue()
        } //endif
    }
    
    func confirmDeleteAlert(completion: @escaping (Bool, Error?) -> Void){ // confirm the deletion b4 deleting
        
        let alert = UIAlertController(title: "Are you sure you want to delete?", message: .none, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler:  {(alert) -> Void in
            self.ret = true
            completion(true, nil)
        } ))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(alert) -> Void in
            self.ret = false
            completion(false, nil)
        }))
        self.present(alert, animated: true)
    }
    
    func checkWishlistExists() {
        if let uid = user?.uid {
            self.rootRef.child("users").child(uid).child("wishlist").observe(.value) {
                (snapshot) in
                if !snapshot.exists() {
                    self.wishlistItems.removeAll()
                    self.tableView.reloadData()
                } else {
                    // wishlist doesn't exist
                }
            }
        }
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addItemDetail" {
            let vc : AddWishItemViewController = segue.destination as! AddWishItemViewController
            vc.delegate = self
            vc.isEditing = false
        }
        if segue.identifier == "EditSegue" {
            let vc : AddWishItemViewController = segue.destination as! AddWishItemViewController
            vc.delegate = self
            vc.isEditing = true
            let index = tableView.indexPathForSelectedRow?.row
            if let i = index {
                currEditItemIdx = i
                vc.item = wishlistItems[i]
                vc.itemId = wishlistItems[i].id
            } else {
                return
            }
        }
    }
    

}
extension WishlistViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if wishlistItems.count == 0 {
            setEmptyView(title: "No wishlist items yet.", message: "Press '+' to add!", messageImage: UIImage(systemName: "multiply.circle.fill")!)
        }
        else {
            restore()
        }
        return wishlistItems.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
          if (editingStyle == .delete) {
            confirmDeleteAlert() {shouldDelete, error in
                if let error = error {
                    print(error)
                    return
                }
                if shouldDelete == false{ return } // do not delete
                else{
                    self.deleteItem(currItem: self.wishlistItems[indexPath.row], itemIdx: indexPath.row)
                    self.tableView.reloadData()
                } // user confirmed delete
            } // comfirm delete action callback
        }
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WishListCell", for: indexPath) as! WishlistTableViewCell
        cell.bgView.layer.cornerRadius = 20.0
        cell.delegate = self
        cell.linkButton.tag = indexPath.row
        // hide link button if no url is specified
        if (wishlistItems[indexPath.row].url.isEmpty) {
            cell.linkButton.isHidden = true
        } else {
            cell.linkButton.isHidden = false
        }
        cell.itemNameLabel.text = wishlistItems[indexPath.row].giftName
        if currEditItemIdx == indexPath.row {
            
            for i in 0...4 {
                let image = UIImage(systemName: "star")
                cell.ratingDisplay[i].image = image
            }
        }
        for i in 0...(wishlistItems[indexPath.row].giftRank - 1) {
            let image = UIImage(systemName: "star.fill")
            cell.ratingDisplay[i].image = image
        }

        return cell
    }
    
    
    func didPressLink(_ tag: Int) {
        if (wishlistItems[tag].url != "") {
            let url: URL = NSURL(string: wishlistItems[tag].url)! as URL

            let activityViewController = UIActivityViewController(activityItems: [ url ], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
            // exclude some activity types from the list (optional)
            activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]

            // present the view controller
            self.present(activityViewController, animated: true, completion: nil)
        }
        else {
            // throw alert: No URL
        }

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

extension WishlistViewController: UITableViewDelegate {
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

