//
//  CreateViewController.swift
//  Settler
//
//  Created by Ever Time Cole on 10/15/18.
//  Copyright © 2018 Ever Time Cole. All rights reserved.
//

import UIKit
import Firebase

class CreateViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate {
    let db = Firestore.firestore()
    let selectionNum = UIPickerView()
    let pollTitle = specialTextView()
    let numOfOptScrollView = UIScrollView()
    var arrayst = ["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""]
    private let myValues: NSArray = ["One","Two","Three","Four", "Five","Six","Seven","Eight", "Nine", "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen"]
    var fieldFrame = CGRect()
    var fieldText = String()
    var fieldTag = Int()
    var fieldInScrollView = Bool()
    var currentAmount = 2
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.contains("\n") {
            textView.resignFirstResponder()
            return false
        } else {
            let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
            let numberOfChars = newText.count
            return numberOfChars < 200
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 0.7, green: 0.8, blue: 1, alpha: 1)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        selectionNum.tag = 33
        self.tabBarItem = UITabBarItem(title: "Create", image: UIImage(named: "Create"), tag: 3)
        selectionNum.frame = CGRect(x: self.view.frame.width*0.05, y: self.view.frame.height*0.025, width: self.view.frame.width*0.9, height: self.view.frame.height*0.2)
        selectionNum.dataSource = self
        selectionNum.delegate = self
        self.view.addSubview(selectionNum)
        pollTitle.frame = CGRect(x: self.view.frame.width*0.04, y: self.view.frame.height*0.025, width: self.view.frame.width*0.92, height: self.view.frame.height*0.08)
        pollTitle.delegate = self
        pollTitle.tag = 1
        pollTitle.returnKeyType = .done
        self.view.addSubview(pollTitle)
        numOfOptScrollView.tag = 34
        numOfOptScrollView.frame = CGRect(x: self.view.frame.width*0.03, y: self.view.frame.height*0.2, width: self.view.frame.width*0.94, height: self.view.frame.height*0.65)
        numOfOptScrollView.backgroundColor = UIColor(red: 0.7, green: 0.8, blue: 1, alpha: 1)
        self.view.addSubview(numOfOptScrollView)
        pickerView(selectionNum, didSelectRow: 1, inComponent: 0)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        zoomIn(textView: textView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        zoomOut(textView: textView)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return myValues.count-1 }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { return "\(myValues[row+1]) Answers"}
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentAmount = row+2
        for subview in numOfOptScrollView.subviews {
            if let chach = subview as? UITextView {
                let strang = chach.text
                arrayst.remove(at: chach.tag-2)
                arrayst.insert(strang ?? "", at: chach.tag-2)
            }
            subview.removeFromSuperview()
        }
        var newArr = arrayst.filter { $0.count > 0 }
        while (newArr.count<16) {
            newArr.append("")
        }
        arrayst = newArr
        var num = CGFloat(0)
        let optHeight = self.view.frame.height*0.09
        while Int(num) < pickerView.selectedRow(inComponent: 0)+2 {
            let textView = specialTextView(frame: CGRect(x: 0, y: CGFloat((optHeight+self.view.frame.height*0.005)*num), width: self.view.frame.width*0.94, height: CGFloat(optHeight)))
            numOfOptScrollView.addSubview(textView)
            textView.returnKeyType = .done
            textView.tag = Int(num)+2
            textView.delegate = self
            textView.attributedText = NSAttributedString(string: arrayst[Int(num)])
            textView.font = UIFont(name: "Avenir-Light", size: 20)
            textView.textAlignment = .center
            num += 1
        }
        let base = UIView()
        numOfOptScrollView.addSubview(base)
        base.topAnchor.constraint(equalTo: numOfOptScrollView.topAnchor, constant: 0).isActive = true
        base.bottomAnchor.constraint(equalTo: numOfOptScrollView.bottomAnchor, constant: -CGFloat((optHeight+self.view.frame.height*0.005)*(num+1))).isActive = true
        let confirmation = UIButton(frame: CGRect(x: numOfOptScrollView.frame.width*0.3, y: CGFloat((optHeight+self.view.frame.height*0.005)*num), width: numOfOptScrollView.frame.width*0.4, height: CGFloat(optHeight)))
        confirmation.backgroundColor = UIColor(red: 1, green: 0.2, blue: 0.8, alpha: 1)
        confirmation.layer.cornerRadius = self.view.frame.height*0.01
        confirmation.addTarget(self, action: #selector(aMethod(sender:)), for: .touchUpInside)
        confirmation.setTitle("Create", for: .normal)
        confirmation.setTitleColor(UIColor.black, for: .normal)
        numOfOptScrollView.addSubview(confirmation)
    }
    
    func zoomIn(textView: UITextView) {
        let blurr = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.regular))
        let lbl = specialLabel(frame: CGRect(x: 0, y: self.view.frame.height*0.01, width: self.view.frame.width, height: self.view.frame.height*0.1))
        fieldFrame = textView.frame
        fieldText = textView.text ?? ""
        fieldTag = textView.tag
        if textView.superview?.tag == 34 {
            fieldInScrollView = true
            textView.frame = self.view.convert(textView.frame, to: self.view)
            textView.frame = CGRect(x: numOfOptScrollView.frame.minX, y: numOfOptScrollView.frame.minY+fieldFrame.minY, width: fieldFrame.width, height: fieldFrame.height)
        } else {
            fieldInScrollView = false
        }
        self.view.addSubview(textView)
        blurr.frame = self.view.frame
        self.view.addSubview(blurr)
        blurr.contentView.addSubview(textView)
        if textView.tag == 1 {
            lbl.text = "Question"
        } else {
            lbl.text = "Answer \(myValues[textView.tag-2])"
        }
        blurr.contentView.addSubview(lbl)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            textView.frame = CGRect(x: self.view.frame.width*0.1, y: self.view.frame.height*0.1, width: self.view.frame.width*0.8, height: self.view.frame.height*0.4)
        })
        blurr.tag = 26
        textView.textAlignment = .natural
    }
    
    func zoomOut(textView: UITextView) {
        if fieldInScrollView == true {
            textView.frame = CGRect(x: self.view.frame.width*0.1-numOfOptScrollView.frame.minX, y: self.view.frame.height*0.1-numOfOptScrollView.frame.minY, width: self.view.frame.width*0.8, height: self.view.frame.height*0.4)
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                textView.frame = self.fieldFrame
            })
            self.numOfOptScrollView.addSubview(textView)
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                textView.frame = self.fieldFrame
            })
            self.view.addSubview(textView)
        }
        for sub in self.view.subviews {
            if sub.tag == 26 {
                sub.removeFromSuperview()
            }
        }
        for subview in numOfOptScrollView.subviews {
            if let chach = subview as? UITextView {
                let strang = chach.text
                arrayst.remove(at: chach.tag-2)
                arrayst.insert(strang ?? "", at: chach.tag-2)
            }
        }
        var newArr = arrayst.filter { $0.count > 0 }
        while (newArr.count<16) {
            newArr.append("")
        }
    }

    @objc func aMethod(sender: AnyObject) {
        
        var data = ["name": (Auth.auth().currentUser?.displayName)!] as [String : Any]
        for subview in numOfOptScrollView.subviews {
            if let chach = subview as? UITextField {
                let strang = chach.text
                arrayst.remove(at: chach.tag)
                arrayst.insert(strang ?? "", at: chach.tag)
            }
        }
        var newArr = arrayst.filter { $0.count > 0 }
        while newArr.count>currentAmount {
            newArr.remove(at: newArr.count-1)
        }
        var num = 0
        for foo in newArr {
            data["opt\(num)"] = [foo, 0]
            num += 1
        }
        if pollTitle.text! != ""{
            if  newArr.count>1 {
                db.collection("Users").document((Auth.auth().currentUser?.displayName)!).setData([pollTitle.text! : 0], merge: true)
                db.collection("Polls").document("\(pollTitle.text!)").setData(data)
                errorMessage(text: "You succesfully uploaded this Poll", view: self.view)
                for subview in self.view.subviews {
                    if let subv = subview as? UITextView {
                        subv.text = ""
                    }
                    if let subb = subview as? UIScrollView {
                        for su in subb.subviews {
                            if let foo = su as? UITextView {
                                foo.text = ""
                            }
                        }
                    }
                }
            } else {
                errorMessage(text: "You need at least two options", view: self.view)
            }
        } else {
            errorMessage(text: "You need to ask a question", view: self.view)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
