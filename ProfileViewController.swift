//
//  ProfileTab.swift
//  Settler
//
//  Created by Ever Time Cole on 10/15/18.
//  Copyright © 2018 Ever Time Cole. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    let db = Firestore.firestore()
    var numOfPoll = 0
    var polls:[String] = []
    var votes:[Int] = []
    let profileLBL = specialLabel()
    let profileBG = UIView()
    
    override func viewDidLoad() {

        self.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "Profile"), tag: 0)
        let bread = UISwipeGestureRecognizer(target: self, action: #selector(self.abMethod))
        bread.direction = .right
        let blead = UISwipeGestureRecognizer(target: self, action: #selector(self.aaMethod))
        blead.direction = .left
        let statsBG = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height*0.0275))
        statsBG.backgroundColor = UIColor.white
        profileBG.frame = CGRect(x: 0, y: self.view.frame.height*0.0275, width: self.view.frame.width, height: self.view.frame.height*0.2)
        profileLBL.frame = CGRect(x: 0, y: self.view.frame.height*0.0275, width: self.view.frame.width, height: self.view.frame.height*0.2)
        profileLBL.textColor = UIColor.white
        profileLBL.text = (Auth.auth().currentUser?.displayName) ?? "offline"
        profileLBL.censorText()
        profileLBL.font = UIFont(name: "Avenir-Light", size: 48)!
        profileBG.backgroundColor = UIColor.black
        self.view.addSubview(profileBG)
        self.view.addSubview(profileLBL)
        self.view.addSubview(statsBG)
        self.view.addGestureRecognizer(bread)
        self.view.addGestureRecognizer(blead)
        updateProfile()
        let button = UIButton(frame: CGRect(x: self.view.frame.width*0.05, y: self.view.frame.height*0.05, width: self.view.frame.width*0.2, height: self.view.frame.height*0.05))
        button.addTarget(self, action: #selector(updateProfile), for: .touchUpInside)
        button.titleLabel?.textColor = UIColor.white
        button.titleLabel?.font = UIFont(name: "Avenir-Light", size: 24)!
        button.setTitle("↻", for: .normal)
        self.view.addSubview(button)
    }
    
    @objc func updateProfile() {
        self.polls.removeAll()
        self.votes.removeAll()
        self.numOfPoll = 0
        db.collection("Users").document((Auth.auth().currentUser?.displayName ?? "Offline")).getDocument { (document, error) in
            if let document = document, document.exists {
                for doc in document.data()! {
                    if doc.key == "a1D6FrGtwoNineEle1" {
                    } else {
                        self.numOfPoll+=1
                        self.polls.append(doc.key)
                        self.votes.append(doc.value as! Int)
                    }
                }
                self.addChoices()
            } else {
                errorMessage(text: "User doesn't exist", view: self.view)
            }
        }

    }
    
    @objc func aMethod(sender: AnyObject) {
        let poll = Poll(frame: CGRect(x: self.view.frame.width*0.02, y: self.view.frame.height*0.04, width: self.view.frame.width*0.96, height: self.view.frame.height*0.8))
        poll.titleText = polls[sender.tag]
        poll.swiped = true
        self.view.addSubview(poll)
    }
    
    func addChoices() {
        for view in self.view.subviews {
            if let vie = view as? UIScrollView {
                vie.removeFromSuperview()
            }
        }
        let optio = CGRect(x: 0, y: self.view.frame.height*0.2275, width: self.view.frame.width, height: self.view.frame.height*0.62)
        let optHeight = self.view.frame.height*0.075
        var num = 0
        let pollScrollView = UIScrollView(frame: optio)
        self.view.addSubview(pollScrollView)
        pollScrollView.showsVerticalScrollIndicator = false
        while num < numOfPoll {
            let button = UIButton(frame: CGRect(x: self.view.frame.width*0.02, y: (optHeight+self.view.frame.height*0.01)*CGFloat(num)+self.view.frame.height*0.01, width: self.view.frame.width*0.88, height: CGFloat(optHeight)))
            let deleteButton = UIButton(frame: CGRect(x: self.view.frame.width*0.9, y: (optHeight+self.view.frame.height*0.01)*CGFloat(num)+self.view.frame.height*0.01, width: self.view.frame.width*0.1, height: optHeight))
            let deleteLBL = specialLabel(frame: deleteButton.frame)
            deleteLBL.text = "⛔️"
            let labelOne = specialLabel(frame: CGRect(x: 4, y: 2, width: button.frame.width*0.6, height: optHeight-4))
            let labelTwo = specialLabel(frame: CGRect(x: button.frame.width*0.6, y: 2, width: button.frame.width*0.4-8, height: optHeight-4))
            labelOne.text = "\(polls[num])"
            labelTwo.text = "\(votes[num])"
            button.layer.borderWidth = 2
            button.layer.cornerRadius = labelOne.frame.height/2
            pollScrollView.addSubview(button)
            pollScrollView.addSubview(deleteButton)
            pollScrollView.addSubview(deleteLBL)
            button.addSubview(labelOne)
            button.addSubview(labelTwo)
            button.tag = num
            deleteButton.tag = num
            button.addTarget(self, action: #selector(self.aMethod(sender:)), for: .touchUpInside)
            deleteButton.addTarget(self, action: #selector(self.bMethod(sender:)), for: .touchUpInside)
            num += 1
        }
        let base = UIView()
        pollScrollView.addSubview(base)
        base.topAnchor.constraint(equalTo: pollScrollView.topAnchor, constant: 0).isActive = true
        base.bottomAnchor.constraint(equalTo: pollScrollView.bottomAnchor, constant: -CGFloat((optHeight+self.view.frame.height*0.01)*CGFloat(num))).isActive = true
    }
        
    func removePolls(dir: CGFloat) {
        for view in self.view.subviews {
            if let cha = view as? Poll {
                animateViewAway(view: cha, dir: dir)
            }
        }
    }
    
    
    @objc func bMethod(sender: AnyObject) {
        let poll = Poll()
        poll.titleText = polls[sender.tag]
        poll.deletePoll()
        db.collection("Users").document((Auth.auth().currentUser?.displayName)!).updateData([
            polls[sender.tag]: FieldValue.delete(),
            ]) { err in
                if err != nil {
                    errorMessage(text: "Failed to delete", view: self.view)
                } else {
                    self.updateProfile()
                }
        }

    }

    
    @objc func aaMethod(sender: AnyObject) {
        removePolls(dir: 1)
    }
    
    @objc func abMethod(sender: AnyObject) {
        removePolls(dir: -1)
    }
    
}
