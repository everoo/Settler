//
//  SettingsViewController.swift
//  Settler
//
//  Created by Ever Time Cole on 10/15/18.
//  Copyright © 2018 Ever Time Cole. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {
    let db = Firestore.firestore()
    let suggestionBox = specialTextView()
    let wordBox = specialTextView()
    let scrollView = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height*0.8)
        self.view.addSubview(scrollView)
        let base = UIView()
        scrollView.addSubview(base)
        base.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0).isActive = true
        base.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -self.view.frame.height*1.3).isActive = true
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        let signOff = UIButton(frame: CGRect(x: self.view.frame.width*0.05, y: self.view.frame.height*0.02, width: self.view.frame.width*0.9, height: self.view.frame.height*0.1))
        let lbl = specialLabel(frame: CGRect(x: self.view.frame.width*0.05, y: self.view.frame.height*0.02, width: self.view.frame.width*0.9, height: self.view.frame.height*0.1))
        lbl.text = "Sign Off"
        signOff.layer.borderWidth = 5
        signOff.layer.cornerRadius = self.view.frame.height*0.02
        signOff.addTarget(self, action: #selector(self.aMethod), for: .touchUpInside)
        scrollView.addSubview(signOff)
        scrollView.addSubview(lbl)
        self.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(named: "Settings"), tag: 4)
        let DAL = specialLabel(frame: CGRect(x: self.view.frame.width*0.05, y: self.view.frame.height*0.13, width: self.view.frame.width*0.9, height: self.view.frame.height*0.1))
        let DAB = UIButton(frame: CGRect(x: self.view.frame.width*0.05, y: self.view.frame.height*0.13, width: self.view.frame.width*0.9, height: self.view.frame.height*0.1))
        DAB.layer.borderWidth = 5
        DAB.layer.cornerRadius = self.view.frame.height*0.02
        DAB.addTarget(self, action: #selector(self.cMethod), for: .touchUpInside)
        DAL.text = "Delete your account"
        scrollView.addSubview(DAL)
        scrollView.addSubview(DAB)

        let suggestLBL = specialLabel(frame: CGRect(x: self.view.frame.width*0.05, y: self.view.frame.height*0.24, width: self.view.frame.width*0.9, height: self.view.frame.height*0.1))
        let SSL = specialLabel(frame: CGRect(x: self.view.frame.width*0.05, y: self.view.frame.height*0.46, width: self.view.frame.width*0.9, height: self.view.frame.height*0.1))
        let sendSuggestion = UIButton(frame: CGRect(x: self.view.frame.width*0.05, y: self.view.frame.height*0.46, width: self.view.frame.width*0.9, height: self.view.frame.height*0.1))
        sendSuggestion.layer.borderWidth = 5
        sendSuggestion.layer.cornerRadius = self.view.frame.height*0.02
        sendSuggestion.addTarget(self, action: #selector(self.bMethod), for: .touchUpInside)
        SSL.text = "Send Suggestion"
        suggestLBL.text = "Send me a suggestion, preferably on how to make this app better"
        suggestionBox.frame = CGRect(x: self.view.frame.width*0.1, y: self.view.frame.height*0.35, width: self.view.frame.width*0.8, height: self.view.frame.height*0.1)
        suggestionBox.layer.cornerRadius = self.view.frame.height*0.02
        scrollView.addSubview(sendSuggestion)
        scrollView.addSubview(SSL)
        scrollView.addSubview(suggestionBox)
        scrollView.addSubview(suggestLBL)

        let wordLBL = specialLabel(frame: CGRect(x: self.view.frame.width*0.05, y: self.view.frame.height*0.6, width: self.view.frame.width*0.9, height: self.view.frame.height*0.1))
        wordLBL.text = "Type in words you no longer want to see. Seperate them by commas"
        wordBox.frame = CGRect(x: self.view.frame.width*0.05, y: self.view.frame.height*0.71, width: self.view.frame.width*0.9, height: self.view.frame.height*0.1)
        let wordBtnLbl = specialLabel(frame: CGRect(x: self.view.frame.width*0.05, y: self.view.frame.height*0.82, width: self.view.frame.width*0.9, height: self.view.frame.height*0.1))
        wordBtnLbl.text = "Set Filter Words"
        let wordBtn = UIButton(frame: CGRect(x: self.view.frame.width*0.05, y: self.view.frame.height*0.82, width: self.view.frame.width*0.9, height: self.view.frame.height*0.1))
        wordBtn.layer.borderWidth = 5
        wordBtn.layer.cornerRadius = self.view.frame.height*0.02
        wordBtn.addTarget(self, action: #selector(self.saveBadWords), for: .touchUpInside)
        scrollView.addSubview(wordLBL)
        scrollView.addSubview(wordBtnLbl)
        scrollView.addSubview(wordBtn)
        scrollView.addSubview(wordBox)
        for word in UserDefaults.standard.stringArray(forKey: "BadWords") ?? [] {
            wordBox.text.append("\(word), ")
        }


        var left = true
        var num:CGFloat = 0
        for bb in UserDefaults.standard.stringArray(forKey: "BadWords") ?? ["x2qw3z"] {
            var tum:CGFloat = 0.55
            if left == true {tum=0.05}
            let lbl = specialLabel(frame: CGRect(x: self.view.frame.width*tum, y: self.view.frame.height*0.93+self.view.frame.height*num, width: self.view.frame.width*0.45, height: self.view.frame.height*0.05))
            lbl.text = bb
            lbl.tag = 768
            scrollView.addSubview(lbl)
            if left == true {left=false} else {left=true; num+=0.06}
        }

    }
    
    @objc func aMethod(sender: AnyObject) {
        try! Auth.auth().signOut()
        self.present(SignIn(), animated: true, completion: {})
    }
    
    @objc func bMethod(sender: AnyObject) {
        if suggestionBox.text != "" {
            if suggestionBox.text.count<300{
                Firestore.firestore().collection("Suggestions").addDocument(data: [
                    "You Should": suggestionBox.text,
                    "Name": UserDefaults.standard.object(forKey: "Username")!
                    ])
                suggestionBox.text = ""
                errorMessage(text: "Thank you for your contribution", view: self.view)
            } else {
                errorMessage(text: "You need less than 300 letters", view: self.view)
            }
        } else {
            errorMessage(text: "You need to type something", view: self.view)
        }
    }
    
    let popUp = UIView()
    @objc func cMethod(sender: AnyObject){
        popUp.frame = CGRect(x: self.view.frame.width*0.25, y: self.view.frame.height*0.25, width: self.view.frame.width*0.5, height: self.view.frame.height*0.3)
        popUp.layer.borderWidth = 1
        popUp.layer.cornerRadius = 5
        popUp.backgroundColor = UIColor.white
        self.view.addSubview(popUp)
        let positive = specialLabel(frame: CGRect(x: 0, y: 0, width: popUp.frame.width, height: popUp.frame.height*0.5))
        popUp.addSubview(positive)
        let yes = UIButton(frame: CGRect(x: 0, y: popUp.frame.height*0.5, width: popUp.frame.width*0.5, height: popUp.frame.height*0.5))
        let yesLBL = specialLabel(frame: CGRect(x: popUp.frame.width*0.05, y: popUp.frame.height*0.55, width: popUp.frame.width*0.4, height: popUp.frame.height*0.4))
        let no = UIButton(frame: CGRect(x: popUp.frame.width*0.5, y: popUp.frame.height*0.5, width: popUp.frame.width*0.5, height: popUp.frame.height*0.5))
        let noLBL = specialLabel(frame: CGRect(x: popUp.frame.width*0.55, y: popUp.frame.height*0.55, width: popUp.frame.width*0.4, height: popUp.frame.height*0.4))
        positive.text = "Are you sure you want to delete your account? All of your polls will be deleted"
        yesLBL.text = "Yes"
        noLBL.text = "No"
        yesLBL.layer.borderWidth = 1
        yesLBL.layer.cornerRadius = self.view.frame.height*0.02
        noLBL.layer.borderWidth = 1
        noLBL.layer.cornerRadius = self.view.frame.height*0.02
        popUp.addSubview(yes)
        popUp.addSubview(no)
        popUp.addSubview(yesLBL)
        popUp.addSubview(noLBL)
        yes.addTarget(self, action: #selector(dMethod(sender:)), for: .touchUpInside)
        no.addTarget(self, action: #selector(eMethod(sender:)), for: .touchUpInside)
    }
    
    @objc func saveBadWords() {
        if wordBox.text.contains("*") == false {
            for view in scrollView.subviews {
                if view.tag == 768 {
                    view.removeFromSuperview()
                }
            }
            var arrayT:[String] = []
            var stringT = ""
            for char in wordBox.text {
                if char == "," {
                    arrayT.append(stringT.lowercased()); stringT = ""
                } else if char == " " {
                } else {
                    stringT.append(char)
                }
            }
            arrayT.append(stringT.lowercased())
            UserDefaults.standard.set(arrayT, forKey: "BadWords")
            errorMessage(text: "Saved unwanted words", view: self.view)
            var left = true
            var num:CGFloat = 0
            for bb in arrayT {
                var tum:CGFloat = 0.55
                if left == true {tum=0.05}
                let lbl = specialLabel(frame: CGRect(x: self.view.frame.width*tum, y: self.view.frame.height*0.93+self.view.frame.height*num, width: self.view.frame.width*0.45, height: self.view.frame.height*0.05))
                lbl.text = bb
                lbl.tag = 768
                scrollView.addSubview(lbl)
                if left == true {left=false} else {left=true; num+=0.06}
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: updateCens), object: nil)
        } else {
            errorMessage(text: "You can't censor the censor (*)", view: self.view)
        }
    }
    
    @objc func dMethod(sender: AnyObject) {
        db.collection("Users").document((Auth.auth().currentUser?.displayName)!).getDocument { (document, error)  in
            if let document = document, document.exists {
                for doc in document.data()! {
                    let poll = Poll()
                    poll.titleText = doc.key
                    poll.deletePoll()
                }
                self.db.collection("Users").document((Auth.auth().currentUser?.displayName)!).delete()
            } else {
                errorMessage(text: error!.localizedDescription, view: self.view)
            }
        }
        Auth.auth().currentUser?.delete { error in
            if error != nil {
                errorMessage(text: "Deletion Failed", view: self.view)
            } else {
                errorMessage(text: "Deletion Succeeded", view: self.view)
                self.present(SignIn(), animated: true, completion: {})
            }
        }
        popUp.removeFromSuperview()
    }
    
    @objc func eMethod(sender: AnyObject) {
        popUp.removeFromSuperview()
    }

}
