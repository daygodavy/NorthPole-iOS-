//
//  OtherUserWishlistViewController.swift
//  northpole
//
//  Created by Davy Chuon on 12/3/19.
//  Copyright © 2019 danielweatrowski. All rights reserved.
//

import UIKit
import Firebase


protocol OuvlwDelegate {
    func makeChanges(followStatus: Bool, uid: String, fullName: String, phoneNum: String)
}


class OtherUserWishListViewController: UIViewController {
    
    var delegate: OuvlwDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameWishlistLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    let rootRef = Database.database().reference(fromURL: "https://santa-f5457.firebaseio.com/")
    let user = Auth.auth().currentUser
    var currUserId: String = ""
    var currUserFN: String = ""
    var currUserLN: String = ""
    var currUserPhoneNum: String = ""
    var currUserFullName: String = ""
    var rank: String?
    var url: String?
    var itemName: String?
    var followStatus: Bool = false
    var wishlistItems: [WishlistGifts] = []

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.followButton.layer.cornerRadius = self.followButton.frame.height / 2
        setGradientBackground()
        currUserFullName = "\(currUserFN) \(currUserLN)"
        nameWishlistLabel.text = "\(currUserFullName)"
        loadItems()
        // check if other user is already followed to change follow label
        checkIfUserFollowed()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.delegate?.makeChanges(followStatus: self.followStatus, uid: currUserId, fullName: currUserFullName, phoneNum: currUserPhoneNum)
    }
    
    func checkIfUserFollowed() {
        if let uid = user?.uid {
            let users = self.rootRef.child("users")
            users.child(uid).child("usersFollowed").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChild(self.currUserId) {
                    self.followStatus = true
                    self.changeLabelToUnfollow()
                }
            })
        }
    }
    
    
    func loadItems() {
        rootRef.child("users").child(currUserId).child("wishlist").observe(.value) { (snapshot) in
            if snapshot.hasChildren() {
                self.getExistingItems(snap: snapshot)
            }
        }
     }
    
    func getExistingItems(snap: DataSnapshot) {
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
            self.tableView.reloadData()
        }
    }
    
    @IBAction func FollowButtonPressed(_ sender: Any) {
        if self.followStatus == false {
            self.followStatus = true
            self.changeLabelToUnfollow()
            self.storeNewFollowing()
        } else {
            self.followStatus = false
            self.changeLabelToFollow()
            self.deleteNewFollowing()
        }
    }
    
    func changeLabelToFollow() {
        if let followImg = UIImage(systemName: "suit.heart") {
            followButton.setImage(followImg, for: .normal)
        }
    }
    
    func changeLabelToUnfollow() {
        if let unfollowImg = UIImage(systemName: "suit.heart.fill") {
            followButton.setImage(unfollowImg, for: .normal)
        }
    }
    
    func storeNewFollowing() {
        if let uid = user?.uid {
            let users = self.rootRef.child("users")
            let newFollowing = users.child(uid).child("usersFollowed").child(currUserId)
            newFollowing.updateChildValues(["Name" : currUserFullName])
            newFollowing.updateChildValues(["phoneNumber": currUserPhoneNum])
            newFollowing.updateChildValues(["UID" : currUserId])
        }
    }
    
    func deleteNewFollowing() {
        if let uid = user?.uid {
            let users = self.rootRef.child("users")
            users.child(uid).child("usersFollowed").child(currUserId).removeValue()
        }
    }
    
}

extension OtherUserWishListViewController: UITableViewDataSource, OtherUserWishlistDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wishlistItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OtherUserWishlistCell", for: indexPath) as! OtherUserWishlistTableViewCell
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
        
        for i in 0...(wishlistItems[indexPath.row].giftRank - 1){
            
            let image = UIImage(systemName: "star.fill")
            cell.ratingDisplay?[i].image = image
        }

        return cell
    }
    
    // Handle when user selects link on item cell
    func didPressLink(_ tag: Int) {
        if (wishlistItems[tag].url != "") {
            let url: URL = NSURL(string: wishlistItems[tag].url)! as URL

            let activityViewController = UIActivityViewController(activityItems: [ url ], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
 
            // present the view controller
            self.present(activityViewController, animated: true, completion: nil)
        }
            // else no URL


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

extension OtherUserWishListViewController: UITableViewDelegate {
    
}
