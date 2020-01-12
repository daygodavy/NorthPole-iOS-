//
//  RecipientDetailViewController.swift
//  northpole
//
//  Created by Daniel Weatrowski on 11/7/19.
//  Copyright © 2019 danielweatrowski. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMLVision

class RecipientDetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: - Properties
    @IBOutlet weak var addGiftButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalAmntSpentLabel: UILabel!
    @IBOutlet weak var totalBudgetLabel: UILabel!
    @IBOutlet weak var GifteeNameLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var scanButton: UIButton!
    
    let rootRef = Database.database().reference(fromURL: "https://santa-f5457.firebaseio.com/")
    let user = Auth.auth().currentUser
    var gifteeGifts: [Giftee.Gifts] = [] // temporary local storage
    
    var totalAmntSpent: Double = 0.0
    var totalNumGifts: Int = 0
    var gifteeName: String = ""
    var currGiftee: Giftee!
    var dic = [String:Double]()
    var initLoadData: Bool = true
    var newGiftName: String = ""
    var newGiftPrice: String = ""
    var allDollars: [String] = []
    var textRecognizer: VisionTextRecognizer!
    var img: UIImage?
    var fbKeyValidator = Validate()
    var alert = AlertManager()
    var giftNameFlag: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        self.checkGifteesCount()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let vision = Vision.vision()
        textRecognizer = vision.onDeviceTextRecognizer()
        setGradientBackground()
        addGiftButton.layer.cornerRadius = addGiftButton.frame.size.height / 2
        scanButton.layer.cornerRadius = scanButton.frame.size.height / 2
        headerView.layer.cornerRadius = 20.0
        self.tableView.dataSource = self
        self.tableView.delegate = self
        // Do any additional setup after loading the view.
        
        GifteeNameLabel.text = gifteeName
        loadGifts()
        hideKeyboardWhenTappedAround()
    }
    
    
    func errorPopUp(){
        
        let ac = UIAlertController(title: "Cannot read image", message: "Please enter image of entire reciept. System cannot read your image", preferredStyle: .alert)
                      ac.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                      self.present(ac, animated: true, completion: nil)
    }
    
    func runTextRecognition(with image:UIImage){
            let visionImage = VisionImage(image: image)
              
              print(visionImage)
              textRecognizer.process(visionImage){ (features, error) in
                                
                self.processResult(from: features, error: error)
                
                if (error != nil){
                    self.errorPopUp()
                    return
                }
                  
              }
        }
        
        
        func processResult(from text: VisionText?, error: Error?){
            
            var linesBefore = [String]()
            var prodName = String()
            var prodPrice = Double()
            
            guard let features = text, let image = img else {
                 errorPopUp()
                return
                
            }
            for block in features.blocks {
                
                for line in block.lines{
                    
                    if line.text.contains("$") {
                        allDollars.append(line.text)
                    }
                    print(line.text)
                    linesBefore.append(line.text)
                    
                }
                
            }
            
            let soldbyIndex = linesBefore.firstIndex(where: {$0.contains("Sold by")}) ?? 100000
            let conditionIndex = linesBefore.firstIndex(where: {$0.contains("Condition")}) ?? 100000
            
            
            if (soldbyIndex  == 100000 || conditionIndex == 100000){
                errorPopUp()
                return
            }
        
            var wantedIndex = min(soldbyIndex,conditionIndex)
            if wantedIndex == 100000 {
                wantedIndex = -1
                
                errorPopUp()
              
                return
            }
            
            if linesBefore == nil {
                errorPopUp()
                return
            }
            print(linesBefore)
            
            var wantedArray = [linesBefore[wantedIndex-6],linesBefore[wantedIndex-6],linesBefore[wantedIndex-5], linesBefore[wantedIndex-4], linesBefore[wantedIndex-3], linesBefore[wantedIndex-2], linesBefore[wantedIndex-1]]
     
            wantedArray = wantedArray.filter {!$0.lowercased().contains("order") && !$0.lowercased().contains("price") && !$0.lowercased().contains("shipped") && !$0.lowercased().contains("delivered") && !$0.contains("$") && !$0.lowercased().contains("v transactions") && !$0.lowercased().contains("placed") &&
                !$0.lowercased().contains("stock") &&
                !$0.lowercased().contains("eligible") &&
                !$0.lowercased().contains("quantity")
            }
           
            if wantedArray.count == 1 {
                prodName = wantedArray[0]
            } else {
                prodName = wantedArray.joined(separator: " ")
            }
            
            
            
            let withoutDollarSign = allDollars.map({item -> String in
                
               
                let temp = item.suffix(from: item.firstIndex(of: "$")!).dropFirst()
                return String(temp)
            }).map({item -> String in
                let letters = NSCharacterSet.letters
                let range = item.rangeOfCharacter(from: letters)

                // range will be nil if no letters is found
                if let _ = range {
                    return self.fixString(item: String(item))
                }
                else {
                    return String(item)
                }
            })
            
            // Store this value
            print(withoutDollarSign.compactMap({Double($0)}).max() ?? -1.1)
            prodPrice = withoutDollarSign.compactMap({Double($0)}).max() ?? -1.1
            print(prodName, prodPrice)
            
            
            if prodName.contains("of: ") {
                if let ind = prodName.firstIndex(of: ":") {
                    prodName = String(prodName.suffix(from: ind))
                    prodName = String(prodName.dropFirst())
                    prodName = String(prodName.dropFirst())
                    prodName = String(prodName.prefix(15))
                }
            }
            self.prepNewGift(amount: prodPrice, name: prodName)
            
        }
        
        func fixString(item: String) -> String {
            return String(Array(item).map{($0 == "O" || $0 == "o") ? "0" : $0})
        }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        img = info[.originalImage] as? UIImage // as! UIImage
        guard let image = img else {
            errorPopUp()
            return
        }
          runTextRecognition(with: image)
          picker.dismiss(animated: true, completion: nil)
      }
      
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
          picker.dismiss(animated: true, completion: nil)
    }
    
    
    
    

    @IBAction func addReciept(_ sender: Any) {

        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let ac = UIAlertController(title: "Photo Source", message: "Choose source", preferredStyle: .actionSheet)
        
        ac.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action:UIAlertAction) in
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated:true,completion: nil)
            
        }))
        
        ac.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {(action:UIAlertAction) in
                
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated:true,completion: nil)
                
        }))
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(ac, animated: true, completion: nil)
        
    }

    @IBAction func addGiftButton(_ sender: Any) {
        let storyboard = UIStoryboard(name:"Main", bundle: .main)

        let alertVC = storyboard.instantiateViewController(identifier: "GiftAlertVC") as! AddGiftViewController

        present(alertVC, animated: true, completion: nil)
        
        
        
    }
    
    @IBAction func unwindToRecipientDetailVC(segue:UIStoryboardSegue) {
        if giftNameFlag && !newGiftName.isEmpty{
            let invalidKeyAlert = alert.alert(title: "Invalid Gift Name", body: "Cannot contain: .,$,#,[,],/", buttonTitle: "OK") {

            }
            present(invalidKeyAlert, animated: true)
        }
        else if let numAmnt = Double(newGiftPrice), newGiftName.count > 0 {
            let roundedAmnt = numAmnt.rounded(digits:2)
            self.prepNewGift(amount: roundedAmnt, name: newGiftName)
        } else if newGiftPrice.count < 1, newGiftName.count > 0 {
            self.prepNewGift(amount: 0, name: newGiftName)
        } else {
            let alert = UIAlertController(title: "Empty Fields", message: "Please enter a name for your gift", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    func prepNewGift(amount: Double, name: String) {
        
        let newGift = Giftee.Gifts.init(gift: name, price: amount)
        self.gifteeGifts.append(newGift)
        
        getAllAmntSpent() {count, error in
            if let error = error {
                print(error)
                return
            }
            //format count and amount
            
            let newCount = count + self.totalAmntSpent
            self.updateAllAmntSpent(count: newCount)
            
        }
        self.updateTotalAmntSpent(price: amount)

        self.storeNewGift()
        
        getAllGiftsCount() {count, error in
                if let error = error {
                    print(error)
                    return
                }
                let newCount = count + 1
                self.updateAllGiftsCount(count: newCount)
                
        }
        
        self.updateNumGifts(count: 1)
        
        
    }
    
//     stores user's new giftee into DB under unique ID
    func storeNewGift() {
        gifteeGifts.forEach { dic.updateValue($0.giftPrice, forKey:$0.giftName) }
        if let uid = user?.uid {
            let users = self.rootRef.child("users")
            users.child(uid).child("giftee").child(gifteeName).child("gifts").updateChildValues(dic)

            self.tableView.reloadData()
        }
    }

    // reads/loads gifts from DB into table view
    func loadGifts() {
        if let uid = user?.uid {            rootRef.child("users").child(uid).child("giftee").child(gifteeName).child("gifts").observe(.value) { (snapshot) in
                if snapshot.hasChildren() {
                    self.getExistingGifts(snap: snapshot)
                } else {
                    self.initLoadData = false
                    self.initGifteeTotalAmnt()
                    self.initNumGifts()
                    //self.initAllGifts()
                }
            }
        }
    }
    
    func getExistingGifts(snap: DataSnapshot) {
        let gifts = snap.value as! Dictionary<String,Double>
        if self.initLoadData {
            for gift in gifts {
                let newGift = Giftee.Gifts.init(gift: gift.key, price: gift.value)
                self.gifteeGifts.append(newGift)
            }
            self.initLoadData = false
            self.tableView.reloadData()
            self.loadGiftsTotalAmnt()
            self.loadNumGifts()
        }
    }
    
    func initGifteeTotalAmnt() {
        if let uid = user?.uid {
            let users = self.rootRef.child("users")
            users.child(uid).child("giftee").child(gifteeName).child("giftsTotalCost").updateChildValues(["cost" : 0])
        }
    }
    
    func updateTotalAmntSpent(price: Double) {
        totalAmntSpent += price
        currGiftee.totalSpent = totalAmntSpent
    
        totalAmntSpentLabel.text = doubleToCurrency(val: totalAmntSpent)
        if let uid = user?.uid {
            let users = self.rootRef.child("users")
            users.child(uid).child("giftee").child(gifteeName).child("giftsTotalCost").updateChildValues(["cost": totalAmntSpent])
        }
        

    }
    
    func updateAllAmntSpent(count: Double){
        if let uid = user?.uid{
            let users = self.rootRef.child("users")
            users.child(uid).child("totalSpending").updateChildValues(["count": count])
        }
    }

    
    func getAllAmntSpent (completion: @escaping (Double, Error?) -> Void){
         if let uid = user?.uid {
                   let users = self.rootRef.child("users")
         
             users.child(uid).child("totalSpending").observeSingleEvent(of: .value, with: { (snapshot) in

             let snap = snapshot.value as! [String: AnyObject]
             let count = snap["count"] as? Double
                let currentValue = count ?? 1000.00
                 
                 completion(currentValue, nil)

             })
         } // end if
     }
    
    
    
    func loadGiftsTotalAmnt() {
        if let uid = user?.uid {            rootRef.child("users").child(uid).child("giftee").child(gifteeName).child("giftsTotalCost").observe(.value) { (snapshot) in

                if snapshot.value != nil && snapshot.exists() {
                    let snap = snapshot.value as! [String:Double]
                    let value = snap["cost"]
                    if let totalAmnt = value {
                        self.totalAmntSpent = totalAmnt
                        self.totalAmntSpentLabel.text = self.doubleToCurrency(val: self.totalAmntSpent)
                    }
                }
            }
        }
    }
    
    func initNumGifts() {
        if let uid = user?.uid {
            let users = self.rootRef.child("users")
            users.child(uid).child("giftee").child(gifteeName).child("giftsCount").updateChildValues(["count" : 0])
        }
    }
    
    func updateNumGifts(count: Int) {
        totalNumGifts += count
    
        currGiftee.totalGifts = totalNumGifts

        if let uid = user?.uid {
            let users = self.rootRef.child("users")
            users.child(uid).child("giftee").child(gifteeName).child("giftsCount").updateChildValues(["count": totalNumGifts])
        }
    }
    

    func updateAllGiftsCount(count: Int){
        if let uid = user?.uid{
            let users = self.rootRef.child("users")
            users.child(uid).child("allGiftsCount").updateChildValues(["count": count])
        }
    }
    
    func getAllGiftsCount (completion: @escaping (Int, Error?) -> Void){
        if let uid = user?.uid {
                  let users = self.rootRef.child("users")
        
            users.child(uid).child("allGiftsCount").observeSingleEvent(of: .value, with: { (snapshot) in

            let snap = snapshot.value as! [String: AnyObject]
            let count = snap["count"] as? Int
            let currentValue = count ?? 1000
                
                completion(currentValue, nil)
            })
        } // end if
    }
    
    func loadNumGifts() {
        if let uid = user?.uid {            rootRef.child("users").child(uid).child("giftee").child(gifteeName).child("giftsCount").observe(.value) { (snapshot) in
            if snapshot.value != nil && snapshot.exists(){
                    let snap = snapshot.value as! [String:Int]
                    let value = snap["count"]
                    if let totalGifts = value {
                        self.totalNumGifts = totalGifts
                    }
                }
            }
        }
    }
    
    func deleteGift(currGift: Giftee.Gifts, giftIdx: Int) {
        self.gifteeGifts.remove(at: giftIdx)
        if let uid = user?.uid {
            let users = self.rootRef.child("users")
            users.child(uid).child("giftee").child(gifteeName).child("gifts").child(currGift.giftName).removeValue()
        }
        
        
        getAllGiftsCount() {count, error in
           if let error = error {
               print(error)
               return
           }
           let newCount = count - 1
           self.updateAllGiftsCount(count: newCount)
           
        }
        
        getAllAmntSpent() {count, error in
           if let error = error {
               print(error)
               return
           }
            let newCount = count - currGift.giftPrice
           self.updateAllAmntSpent(count: newCount)
           
         }
        
        
        self.updateTotalAmntSpent(price: -currGift.giftPrice)
        self.updateNumGifts(count: -1)
    }
    
    func checkGifteesCount() {
        if let uid = user?.uid {
            rootRef.child("users").child(uid).child("gifteesCount").observe(.value) { (snapshot) in
            if snapshot.value != nil && snapshot.exists(){
                    let snap = snapshot.value as! [String:Int]
                    let value = snap["count"]
                    if let totalGiftees = value {
                        if totalGiftees == 0 {
                            self.deleteGiftees(); self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
    }
    
    func deleteGiftees() {
            if let uid = user?.uid {
                let users = self.rootRef.child("users")
                users.child(uid).child("giftee").removeValue {error,arg  in
                    if error != nil {
                        print("\(error!)")
                    }
                }
            }
    }
    
    func doubleToCurrency(val: Double) -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current

        let priceString = currencyFormatter.string(from: NSNumber(value: val))!
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
    
    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension RecipientDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if gifteeGifts.count == 0 {
            setEmptyView(title: "No gifts for this giftee yet.", message: "Press '+' to add!", messageImage: UIImage(systemName: "multiply.circle.fill")!)
        }
        else {
            restore()
        }
        
        return gifteeGifts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GiftCell", for: indexPath) as! GiftTableViewCell
        cell.bgView.layer.cornerRadius = 20.0

        cell.itemLabel.text = gifteeGifts[indexPath.row].giftName
        cell.priceLabel.text = doubleToCurrency(val: gifteeGifts[indexPath.row].giftPrice)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
        

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            self.deleteGift(currGift: self.gifteeGifts[indexPath.row], giftIdx: indexPath.row)
            self.tableView.reloadData()
        }
    }
    
}

extension RecipientDetailViewController {
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


