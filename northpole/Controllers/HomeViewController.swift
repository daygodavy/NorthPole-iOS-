//
//  HomeViewController.swift
//  northpole
//
//  Created by Daniel Weatrowski on 11/7/19.
//  Copyright © 2019 danielweatrowski. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController, SettingsDelegate {
    func makeUpdates() {
        updateUI()
    }
    
// MARK: - Properties
    @IBAction func settingsButtonPressed(_ sender: Any) {
        
        performSegue(withIdentifier: "goToSettings", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSettings" {
            guard let accVC = segue.destination as? SettingsViewController else {
                return
            }
            accVC.delegate = self
            
        }
    }
    
    
    
    let maxHeaderHeight: CGFloat = 220
    let minHeaderHeight: CGFloat = 140
    let minTitleConstraint : CGFloat = 60
    let maxTitleConstraint: CGFloat = 150

    // The last known scroll position
    var previousScrollOffset: CGFloat = 0

    // The last known height of the scroll view content
    var previousScrollViewHeight: CGFloat = 0
    
    @IBOutlet weak var ContentView: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var headerHeightConstaint: NSLayoutConstraint!

    @IBOutlet weak var titleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var spendingsView: UIView!
    @IBOutlet weak var gifteeView: UIView!
    @IBOutlet weak var giftView: UIView!
    @IBOutlet weak var countDownView: UIView!
    
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var secLabel: UILabel!
    
    @IBOutlet weak var spendingsLabel: UILabel!
    @IBOutlet weak var numGiftsLabel: UILabel!
    @IBOutlet weak var numGifteesLabel: UILabel!
    
    @IBOutlet weak var daysTilView: UIView!
    @IBOutlet weak var overviewView: UIView!
    let rootRef = Database.database().reference(fromURL: "https://santa-f5457.firebaseio.com/")
    let user = Auth.auth().currentUser
    
    
    var timer = Timer()

    // Hard coded for December 25th 2019
    // Find a more elegant way to get upcoming Christmas regardless of the year
    // Make sure this is in the future
    let futureDate: Date? = {
        let calendar = Calendar.current
        var future = DateComponents(
            year: calendar.component(.year, from: Date()),
            month: 12,
            day: 25,
            hour: 0,
            minute: 0,
            second: 0
        )
        return Calendar.current.date(from: future)
    }()

    var countdown: DateComponents? {

        guard let future = futureDate else {
            return nil
        }

        return Calendar.current.dateComponents([.day, .hour, .minute, .second], from: Date(), to: future)
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.delegate = self
        spendingsView.layer.cornerRadius = 20.0
        giftView.layer.cornerRadius = 20
        gifteeView.layer.cornerRadius = 20
        countDownView.layer.cornerRadius = 20.0
        overviewView.layer.cornerRadius = 20.0
        daysTilView.layer.cornerRadius = 20.0
        setGradientBackground(view: ContentView)
        
        
        updateUI()

    }
  
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(true)
            updateUI()
            runTimer()
        print("homeview view will appear")
    }
    
    func updateUI(){
        
        if let uid = user?.uid {
                    let users = self.rootRef.child("users")
          
              users.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                
                
                if snapshot.hasChildren() { // grab data
                    let snap = snapshot.value as! [String: AnyObject]
                    let allGiftsCount = (snap["allGiftsCount"]?["count"] as? Int) ?? 0
                    let gifteeCount = (snap["gifteesCount"]?["count"] as? Int) ?? 0
                    let userSpendings = (snap["totalSpending"]?["count"] as? Double) ?? 0.0
                    let totalSpending = userSpendings.rounded(digits: 2)

                    self.numGiftsLabel.text = "\(max(allGiftsCount, 0))"
                    self.numGifteesLabel.text = "\(max(gifteeCount, 0))"
                    self.spendingsLabel.text = doubleToCurrency(val: totalSpending)

                }
                else{
                    users.child(uid).child("gifteesCount").updateChildValues(["count" : 0])
                    users.child(uid).child("allGiftsCount").updateChildValues(["count" : 0])
                    users.child(uid).child("totalSpending").updateChildValues(["count" : 0])
                }
              })
          } // end if
    
        
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
        
}
    

        func runTimer() {

             timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(HomeViewController.updateTimer)), userInfo: nil, repeats: true)
        }

        @objc func updateTimer() {

            guard let countdown = self.countdown else {
                return
            }

            guard let days = countdown.day, let hours = countdown.hour, let minutes = countdown.minute, let seconds = countdown.second else {
                print("Error: Inside updateCountDown guard")
                return
            }

            if days + hours + minutes + seconds == 0 {
                timer.invalidate()
                
            } else {

                dayLabel.text = String(format: "%02d", days)
                hourLabel.text = String(format: "%02d", hours)
                minLabel.text = String(format: "%02d", minutes)
                secLabel.text = String(format: "%02d", seconds)


            }
        }


    }

        
    func setGradientBackground(view: UIView) {
        let colorTop = UIColor.white.cgColor
        let colorBottom = UIColor(red:0.92, green:0.93, blue:0.96, alpha:1.0).cgColor

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = view.bounds

        view.layer.insertSublayer(gradientLayer, at:0)
    }




extension HomeViewController: UIScrollViewDelegate {

    
}

extension Double {
    func rounded(digits: Int) -> Double {
        let multiplier = pow(10.0, Double(digits))
        return (self * multiplier).rounded() / multiplier
    }
}


