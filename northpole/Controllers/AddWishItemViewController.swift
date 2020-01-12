//
//  AddWishItemViewController.swift
//  northpole
//
//  Created by Daniel Weatrowski on 11/22/19.
//  Copyright © 2019 danielweatrowski. All rights reserved.
//


protocol WishListAddItem {
    func itemAdded(itemField: String?, URLField: String?, rank: Int?, editStatus: Bool?, id: String?)
}


import UIKit

class AddWishItemViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var addItemField: UITextField!
    @IBOutlet weak var addURLField: UITextField!
    @IBOutlet weak var itemView: UIView!
    @IBOutlet weak var urlView: UIView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var newOrEditLabel: UILabel!
    
    
    @IBOutlet var giftRank: [UIButton]!
    let starFill = UIImage(systemName: "star.fill")
    let starNoFill = UIImage(systemName: "star")
    var rank = -1
    var item = WishlistGifts()
    var itemId = "-1"
    
    var delegate: WishListAddItem? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addItemField.delegate = self
        self.addURLField.delegate = self
        self.itemView.layer.cornerRadius = 20.0
        self.urlView.layer.cornerRadius = 20.0
        self.addButton.layer.cornerRadius = 20.0
        if (self.isEditing) {
            setUpEditor()
        }
        northpole.setGradientBackground(view: view)
        hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func didPressCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func addItemAction(_ sender: Any) {
        
        let inputValidated = processRank()
        print(inputValidated)

        if ( self.delegate != nil && inputValidated == true) {
            if let item = addItemField.text, let url = addURLField.text{
                self.delegate?.itemAdded(itemField: item, URLField: url, rank: rank, editStatus: isEditing, id: itemId)
                dismiss(animated: true)
              }// endIF
            
        }// endIF
      else{
          print("Input could not be validated")
          return
      }
        
    }
    func setUpEditor() {
        newOrEditLabel.text = "Edit"
        addItemField.text = item.giftName
        addURLField.text = item.url
        addButton.setTitle("Save", for: .normal)
    }
    func processRank() -> Bool{ // process the input entered in rank
        
        let alert = UIAlertController(title: "Please enter all required fields", message: "You must select the rank and enter a name to continue", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        
        if (rank < 1){
            print("Need to add a rank")
            self.present(alert, animated: true)
            return false
        }
        
        let str = addItemField.text
        let trimmed = str?.trimmingCharacters(in: .whitespacesAndNewlines)

        if(trimmed == "" ){
            print("Need to add a name")
            self.present(alert, animated: true)
            return false
        }
        else{
            
            return true
        }
        
        
    }
    
    @IBAction func selected1(_ sender: UIButton) {
        
        giftRank[0].isSelected = true
        giftRank[1].isSelected = false
        giftRank[2].isSelected = false
        giftRank[3].isSelected = false
        giftRank[4].isSelected = false
        rank = 1
        

        giftRank[0].imageView?.contentMode = UIView.ContentMode.scaleAspectFill
        giftRank[0].setImage(starFill, for: .normal)
        giftRank[0].contentVerticalAlignment = .fill
        giftRank[0].contentHorizontalAlignment = .fill

        for i in 1...4{
    
            giftRank[i].imageView?.contentMode = UIView.ContentMode.scaleAspectFill
            giftRank[i].setImage(starNoFill, for: .normal)
            giftRank[i].contentVerticalAlignment = .fill
            giftRank[i].contentHorizontalAlignment = .fill


        }
        
        
    }
    
    
    @IBAction func selected2(_ sender: UIButton) {
        
        giftRank[0].isSelected = false
        giftRank[1].isSelected = true
        giftRank[2].isSelected = false
        giftRank[3].isSelected = false
        giftRank[4].isSelected = false
        rank = 2
        
        for i in 0...1{
             giftRank[i].imageView?.contentMode = UIView.ContentMode.scaleAspectFill
             giftRank[i].setImage(starFill, for: .normal)
             giftRank[i].contentVerticalAlignment = .fill
             giftRank[i].contentHorizontalAlignment = .fill
        }
             
        for i in 2...4{
            giftRank[i].imageView?.contentMode = UIView.ContentMode.scaleAspectFill
            giftRank[i].setImage(starNoFill, for: .normal)
             giftRank[i].contentVerticalAlignment = .fill
            giftRank[i].contentHorizontalAlignment = .fill
        }
        
        
    }
    
    
    @IBAction func selected3(_ sender: UIButton) {
        giftRank[0].isSelected = false
        giftRank[1].isSelected = false
        giftRank[2].isSelected = true
        giftRank[3].isSelected = false
        giftRank[4].isSelected = false
        rank = 3
        
        for i in 0...2{
                giftRank[i].imageView?.contentMode = UIView.ContentMode.scaleAspectFill
                giftRank[i].setImage(starFill, for: .normal)
                giftRank[i].contentVerticalAlignment = .fill
                giftRank[i].contentHorizontalAlignment = .fill
      
            }
        
        for i in 3...4{
                giftRank[i].imageView?.contentMode = UIView.ContentMode.scaleAspectFill
                giftRank[i].setImage(starNoFill, for: .normal)
                giftRank[i].contentVerticalAlignment = .fill
                giftRank[i].contentHorizontalAlignment = .fill
            }
        
    }
    
    @IBAction func selected4(_ sender: UIButton) {
        
        giftRank[0].isSelected = false
        giftRank[1].isSelected = false
        giftRank[2].isSelected = false
        giftRank[3].isSelected = true
        giftRank[4].isSelected = false
        rank = 4
        
        for i in 0...3{
            giftRank[i].imageView?.contentMode = UIView.ContentMode.scaleAspectFill
            giftRank[i].setImage(starFill, for: .normal)
            giftRank[i].contentVerticalAlignment = .fill
            giftRank[i].contentHorizontalAlignment = .fill
        }
        
        giftRank[4].imageView?.contentMode = UIView.ContentMode.scaleAspectFill
        giftRank[4].setImage(starNoFill, for: .normal)
        giftRank[4].contentVerticalAlignment = .fill
        giftRank[4].contentHorizontalAlignment = .fill
  
    }
    @IBAction func selected5(_ sender: UIButton) {
        
        giftRank[0].isSelected = false
        giftRank[1].isSelected = false
        giftRank[2].isSelected = false
        giftRank[3].isSelected = false
        giftRank[4].isSelected = true
        rank = 5
        
        for i in 0...4{
            giftRank[i].imageView?.contentMode = UIView.ContentMode.scaleAspectFill
            giftRank[i].setImage(starFill, for: .normal)
            giftRank[i].contentVerticalAlignment = .fill
            giftRank[i].contentHorizontalAlignment = .fill
        
        }
    }
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

 
        func setGradientBackground() {
            let colorTop = UIColor.white.cgColor
            let colorBottom = UIColor(named: "NPRed")
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [colorTop, colorBottom!]
            gradientLayer.locations = [0.0, 1.0]
            gradientLayer.frame = self.view.bounds

            self.view.layer.insertSublayer(gradientLayer, at:0)
        }

    

}

