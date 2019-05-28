//
//  'user.swift
//  Settler
//
//  Created by Ever Time Cole on 1/18/19.
//  Copyright © 2019 Ever Time Cole. All rights reserved.
//

import UIKit
import Firebase

class User: UIView {
    var panGestureRecognizer : UIPanGestureRecognizer?

    let db = Firestore.firestore()
    var numOfPoll = 0
    var polls:[String] = []
    var votes:[Int] = []
    var usersName = String()

    override func didMoveToSuperview() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        self.addGestureRecognizer(panGestureRecognizer!)
        self.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(self.flagPoll(sender:))))
        self.backgroundColor = UIColor.white
        self.layer.borderWidth = 3
        let profileBG = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height*0.2))
        let profileLBL = specialLabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height*0.2))
        profileLBL.textColor = UIColor.white
        profileLBL.font = UIFont(name: "Avenir-Light", size: 48)!
        profileBG.backgroundColor = UIColor.black
        profileBG.layer.cornerRadius = profileBG.frame.height/2
        self.layer.cornerRadius = profileBG.frame.height/2
        profileLBL.text = usersName
        self.addSubview(profileBG)
        self.addSubview(profileLBL)
        db.collection("Users").document(usersName).getDocument { (document, error) in
            if let document = document, document.exists {
                for doc in document.data()! {
                    if doc.key == "a1D6FrGtwoNineEle1" {
                    } else {
                        self.numOfPoll+=1
                        self.polls.append(doc.key)
                        self.votes.append(doc.value as! Int)
                    }
                }
                if UserDefaults.standard.stringArray(forKey: "FlaggedUser")?.contains(self.usersName) ?? false {
                    self.unexistIt()
                } else {
                    self.addChoices()
                }
            } else {
                let lbl = specialLabel(frame: CGRect(x: self.frame.width*0.25, y: self.frame.height*0.25, width: self.frame.width*0.5, height: self.frame.height*0.5))
                lbl.text = censor(string: "User does not exist")
                self.addSubview(lbl)
            }
        }

    }
    
    @objc func aMethod(sender: AnyObject) {
        let poll = Poll(frame: CGRect(x: self.superview!.frame.width*0.07, y: self.superview!.frame.height*0.2, width: self.frame.width*0.96, height: self.frame.height*0.96))
        poll.titleText = polls[sender.tag]
        poll.swiped = true
        poll.tag = 3
        self.superview?.addSubview(poll)
    }
    
    let popUp = UIView()
    @objc func flagPoll(sender: AnyObject){
        if UserDefaults.standard.stringArray(forKey: "FlaggedUser")?.contains(self.usersName) ?? false {
        } else {
            popUp.frame = CGRect(x: self.frame.width*0.25, y: self.frame.height*0.25, width: self.frame.width*0.5, height: self.frame.height*0.3)
            popUp.layer.borderWidth = 1
            popUp.layer.cornerRadius = 5
            popUp.backgroundColor = UIColor.white
            self.addSubview(popUp)
            let positive = specialLabel(frame: CGRect(x: 0, y: 0, width: popUp.frame.width, height: popUp.frame.height*0.5))
            popUp.addSubview(positive)
            let yes = UIButton(frame: CGRect(x: 0, y: popUp.frame.height*0.5, width: popUp.frame.width*0.5, height: popUp.frame.height*0.5))
            let yesLBL = specialLabel(frame: CGRect(x: popUp.frame.width*0.05, y: popUp.frame.height*0.55, width: popUp.frame.width*0.4, height: popUp.frame.height*0.4))
            let no = UIButton(frame: CGRect(x: popUp.frame.width*0.5, y: popUp.frame.height*0.5, width: popUp.frame.width*0.5, height: popUp.frame.height*0.5))
            let noLBL = specialLabel(frame: CGRect(x: popUp.frame.width*0.55, y: popUp.frame.height*0.55, width: popUp.frame.width*0.4, height: popUp.frame.height*0.4))
            positive.text = "Flag this user? They will be reviewed within 24 hours and removed if found to violate rules. There is no way for your account to see this account again."
            yesLBL.text = "Yes"
            noLBL.text = "No"
            yesLBL.layer.borderWidth = 1
            yesLBL.layer.cornerRadius = self.frame.height*0.02
            noLBL.layer.borderWidth = 1
            noLBL.layer.cornerRadius = self.frame.height*0.02
            popUp.addSubview(yes)
            popUp.addSubview(no)
            popUp.addSubview(yesLBL)
            popUp.addSubview(noLBL)
            yes.addTarget(self, action: #selector(dMethod), for: .touchUpInside)
            no.addTarget(self, action: #selector(dNMethod), for: .touchUpInside)
        }
    }
    
    func unexistIt() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
        let lbl = specialLabel(frame: CGRect(x: self.frame.width*0.25, y: self.frame.height*0.25, width: self.frame.width*0.5, height: self.frame.height*0.5))
        lbl.text = "User can't be seen"
        self.addSubview(lbl)
    }

    @objc func dMethod() {
        db.collection("FlaggedUser").addDocument(data: [
            "User" : "\(self.usersName)",
            "Sender" : "\(Auth.auth().currentUser?.displayName ?? "unknown")"
            ])
        var arraay = UserDefaults.standard.stringArray(forKey: "FlaggedUser")
        arraay?.append(usersName)
        UserDefaults.standard.set(arraay, forKey: "FlaggedUser")
        unexistIt()
    }
    @objc func dNMethod() { popUp.removeFromSuperview() }

    
    func addChoices() {
        for view in self.subviews {
            if let vv = view as? UIScrollView {
                vv.removeFromSuperview()
            }
        }
        let optio = CGRect(x: self.frame.width*0.08, y: self.frame.height*0.19, width: self.frame.width*0.84, height: self.frame.height*0.81)
        let optHeight = self.frame.height*0.1
        var num = 0
        let pollScrollView = UIScrollView(frame: CGRect(x: optio.minX, y: optio.minY, width: optio.width, height: optio.height))
        self.addSubview(pollScrollView)
        pollScrollView.showsVerticalScrollIndicator = false
        while num < numOfPoll {
            let button = UIButton(frame: CGRect(x: 0, y: (optHeight+self.frame.height*0.01)*CGFloat(num)+self.frame.height*0.01, width: pollScrollView.frame.width, height: CGFloat(optHeight)))
            let labelOne = specialLabel(frame: CGRect(x: button.frame.width*0.02, y: 2, width: button.frame.width*0.68, height: optHeight-4))
            let labelTwo = specialLabel(frame: CGRect(x: button.frame.width*0.68, y: 2, width: button.frame.width*0.26, height: optHeight-4))
            labelOne.text = "\(polls[num])"
            labelTwo.text = "\(votes[num])"
            button.layer.borderWidth = 2
            button.layer.cornerRadius = button.frame.height/2
            pollScrollView.addSubview(button)
            button.addSubview(labelOne)
            button.addSubview(labelTwo)
            button.tag = num
            button.addTarget(self, action: #selector(self.aMethod(sender:)), for: .touchUpInside)
            num += 1
        }
        let base = UIView()
        pollScrollView.addSubview(base)
        base.topAnchor.constraint(equalTo: pollScrollView.topAnchor, constant: 0).isActive = true
        base.bottomAnchor.constraint(equalTo: pollScrollView.bottomAnchor, constant: -CGFloat((optHeight+self.frame.height*0.01)*CGFloat(num))).isActive = true
    }
    
    @objc func panGestureAction(_ panGesture: UIPanGestureRecognizer) {
        let translation = panGesture.translation(in: self)
        let velocity = panGesture.velocity(in: self)
        switch panGesture.state {
        case .began:
            break
        case .changed:
            self.transform = CGAffineTransform(rotationAngle: translation.x / .pi / CGFloat(-180)).concatenating(CGAffineTransform(translationX: translation.x / .pi, y: (abs(translation.x) * .pi / CGFloat(180)) * (abs(translation.x) * .pi / CGFloat(180)) * -1))
            break
        case .ended:
            if velocity.x > 250 || velocity.x < -250{
                UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: {
                    self.center.x += velocity.x/3
                    self.center.y += (abs(translation.x) * .pi / CGFloat(90)) * -(abs(translation.x) / CGFloat(90))
                    self.alpha = 0
                }, completion: {(finished:Bool) in
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: goToNext), object: nil)
                    self.removeFromSuperview()
                })
            } else {
                UIView.animate(withDuration: 0.15, animations: {
                    self.transform = CGAffineTransform(rotationAngle: translation.x / -4 / .pi / CGFloat(-180)).concatenating(CGAffineTransform(translationX: translation.x / -4 / .pi, y: (abs(translation.x / -4) * .pi / CGFloat(180)) * (abs(translation.x / -4) * .pi / CGFloat(180))))
                }, completion: {(finished:Bool) in
                    UIView.animate(withDuration: 0.05, animations: {
                        self.transform = CGAffineTransform(rotationAngle:  0).concatenating(CGAffineTransform(translationX: 0, y: 0))
                    })
                })
            }
            break
        case .cancelled:
            UIView.animate(withDuration: 0.15, animations: {
                self.transform = CGAffineTransform(rotationAngle: translation.x / -4 / .pi / CGFloat(-180)).concatenating(CGAffineTransform(translationX: translation.x / -4 / .pi, y: (abs(translation.x / -4) * .pi / CGFloat(180)) * (abs(translation.x / -4) * .pi / CGFloat(180))))
            }, completion: {(finished:Bool) in
                UIView.animate(withDuration: 0.05, animations: {
                    self.transform = CGAffineTransform(rotationAngle:  0).concatenating(CGAffineTransform(translationX: 0, y: 0))
                })
            })
            break
        default:
            break
        }
    }

    
}
