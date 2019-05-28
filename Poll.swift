//
//  Poll.swift
//  Settler
//
//  Created by Ever Time Cole on 11/17/18.
//  Copyright © 2018 Ever Time Cole. All rights reserved.
//

import UIKit
import Firebase

let goToNext = "goToNext"

class Poll: UIView {
    var panGestureRecognizer : UIPanGestureRecognizer?

    let db = Firestore.firestore()
    var swiped = false
    var mode = false
    var chosenOpt = Int()
    var percentages:[CGFloat] = []
    var options:[String] = []
    var keys:[String] = []
    
    let title = specialLabel()
    let person = specialLabel()
    let votes = specialLabel()
    var titleText = ""
    var name = ""
    var voters = CGFloat(0)

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
            if velocity.x > 200 || velocity.x < -200{
//                if self.swiped == true {
                    UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: {
                        self.center.x += velocity.x/3
                        self.center.y += (abs(translation.x) * .pi / CGFloat(90)) * -(abs(translation.x) / CGFloat(90))
                        self.alpha = 0
                    }, completion: {(finished:Bool) in
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: goToNext), object: nil)
                        self.removeFromSuperview()
                    })
//                } else {
//                    shakeView(view: self, dirt: velocity.x)
//                    self.swiped = true
//                }
            } else {
                UIView.animate(withDuration: 0.15, animations: {
                    self.transform = CGAffineTransform(rotationAngle: translation.x / -4 / .pi / CGFloat(-180)).concatenating(CGAffineTransform(translationX: translation.x / -4 / .pi, y: (abs(translation.x / -4) * .pi / CGFloat(180)) * (abs(translation.x / -4) * .pi / CGFloat(180))))
                }, completion: {(finished:Bool) in
                    UIView.animate(withDuration: 0.08, animations: {
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
    
    override func didMoveToSuperview() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        self.addGestureRecognizer(panGestureRecognizer!)
        self.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(self.flagPoll(sender:))))
        title.frame = CGRect(x: self.frame.width*0.01, y: self.frame.height*0.005, width: self.frame.width*0.98, height: self.frame.height*0.095)
        title.font = UIFont(name: "Avenir-Black`", size: 24)
        person.frame = CGRect(x: 0, y: self.frame.height*0.1, width: self.frame.width*0.5, height: self.frame.height*0.05)
        votes.frame = CGRect(x: self.frame.width*0.5, y: self.frame.height*0.1, width: self.frame.width*0.5, height: self.frame.height*0.05)
        self.layer.borderWidth = 2
        self.layer.cornerRadius = self.frame.width*0.05
        self.layer.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 1, alpha: 1).cgColor
        addSubview(title)
        addSubview(person)
        addSubview(votes)
        db.collection("Polls").document(titleText).getDocument { (document, error) in
            if let document = document, document.exists {
                for doc in document.data()! {
                    if doc.key.contains("name") {
                        self.name = doc.value as? String ?? "Someone"
                    }
                    if doc.key.contains("opt") {
                        let coodo = doc.value as? Array ?? ["", 0]
                        self.options.append(coodo[0] as! String)
                        self.percentages.append(coodo[1] as! CGFloat)
                        self.keys.append(doc.key)
                    }
                }
                self.voters = self.percentages.reduce(0, { x, y in x + y })
                self.updateView()
                self.addOptions(numberOfOptions: CGFloat(self.options.count))
                if UserDefaults.standard.stringArray(forKey: "votedOn")?.contains(self.titleText) ?? false {
                    self.swiped = true
                    self.mode = true
                    self.animate()
                }
                if UserDefaults.standard.stringArray(forKey: "FlaggedUser")?.contains(self.name) ?? false {
                    self.unexistIt(text: "You flagged this user")
                }
                if UserDefaults.standard.stringArray(forKey: "FlaggedPoll")?.contains(self.titleText) ?? false {
                    self.unexistIt(text: "You flagged this poll")
                }
            } else {
                self.unexistIt(text: "Poll does not exist")
            }
        }
    }
    
    func unexistIt(text: String) {
        for view in self.subviews {
            view.removeFromSuperview()
        }
        let lbl = specialLabel(frame: CGRect(x: self.frame.width*0.25, y: self.frame.height*0.25, width: self.frame.width*0.5, height: self.frame.height*0.5))
        lbl.text = text
        self.addSubview(lbl)
        self.swiped = true
        self.mode = true
    }
    
    func addOptions(numberOfOptions: CGFloat) {
        let optio = CGRect(x: self.frame.width*0.05, y: self.frame.height*0.155, width: self.frame.width*0.9, height: self.frame.height*0.815)
        let optHeight = self.frame.height*0.125
        var num = CGFloat(0)
        if numberOfOptions*(3+optHeight)<optio.height {
            while num < numberOfOptions {
                let button = specialButton(frame: CGRect(x: optio.minX, y: optio.minY+optio.height/numberOfOptions*num, width: optio.width, height: optio.height/numberOfOptions-3))
                button.text = censor(string: options[Int(num)])
                button.lbl.originalText =  options[Int(num)]
                button.percentage =  percentages[Int(num)]/voters
                button.voteAmount = percentages[Int(num)]
                button.tag = Int(num)
                self.addSubview(button)
                num += 1
            }
        } else {
            let optionScrollView = UIScrollView(frame: CGRect(x: optio.minX, y: optio.minY, width: optio.width, height: optio.height))
            self.addSubview(optionScrollView)
            while num < numberOfOptions {
                let button = specialButton(frame: CGRect(x: 0, y: CGFloat((optHeight+self.frame.height*0.01)*num), width: self.frame.width*0.88, height: CGFloat(optHeight)))
                button.percentage = percentages[Int(num)]/voters
                button.text = censor(string: options[Int(num)])
                button.voteAmount = percentages[Int(num)]
                button.tag = Int(num)
                optionScrollView.addSubview(button)
                num += 1
            }
            let base = UIView()
            optionScrollView.addSubview(base)
            base.topAnchor.constraint(equalTo: optionScrollView.topAnchor, constant: 0).isActive = true
            base.bottomAnchor.constraint(equalTo: optionScrollView.bottomAnchor, constant: -CGFloat((optHeight+self.frame.height*0.01)*num)).isActive = true
        }
    }
    
    var newPercentages:[CGFloat] = []
    var newOptions:[String] = []
    var newKeys:[String] = []
    
    func vote() {
        if mode == false {
            mode = true
            swiped = true
            self.voters+=1
            self.updateView()
            var arraay = UserDefaults.standard.stringArray(forKey: "votedOn")
            arraay?.append(titleText)
            UserDefaults.standard.set(arraay, forKey: "votedOn")
            db.collection("Polls").document(titleText).getDocument { (document, error) in
                if let document = document, document.exists {
                    let trump = self.keys[self.chosenOpt]
                    for doc in document.data()! {
                        if doc.key.contains(trump) {
                            let coodo = doc.value as? Array ?? ["", 0]
                            let oldPercent = coodo[1] as! CGFloat
                            let newPercent = oldPercent+1
                            self.db.collection("Polls").document(self.titleText).updateData([
                                trump: [coodo[0], newPercent]
                            ]) { err in if let err = err { print(err) } else { } }
                        }
                    }
                    for doc in document.data()! {
                        if doc.key.contains("name") {
                            self.name = doc.value as? String ?? "Someone"
                        }
                        if doc.key.contains("opt") {
                            let coodo = doc.value as? Array ?? ["", 0]
                            self.newOptions.append(coodo[0] as! String)
                            self.newPercentages.append(coodo[1] as! CGFloat)
                            self.newKeys.append(doc.key)
                        }
                    }
                    self.percentages = self.newPercentages
                    self.options = self.newOptions
                    self.keys = self.newKeys
                    self.updateView()
                    self.voters = (self.percentages.reduce(0, { x, y in x + y })) + 1
                    self.db.collection("Users").document(self.name).updateData([
                        self.titleText: self.voters
                    ]) { err in if let err = err { print(err) } else { } }

                    self.animate()
                } else {
                    errorMessage(text: "Poll no longer exists", view: self)
                }
            }
        }
    }

    let popUp = UIView()
    @objc func flagPoll(sender: AnyObject){
        if UserDefaults.standard.stringArray(forKey: "FlaggedPoll")?.contains(self.titleText) ?? false {
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
            positive.text = "Flag this poll? It will be reviewed within 24 hours and removed if found to violate rules. There is no way for this account to see this again."
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
            yes.addTarget(self, action: #selector(respondsYes), for: .touchUpInside)
            no.addTarget(self, action: #selector(respondsNo), for: .touchUpInside)
        }
    }

    
    @objc func respondsYes() {
        db.collection("FlaggedPoll").addDocument(data: [
            "Creator" : "\(self.name)",
            "Poll" : "\(self.titleText)",
            "Sender" : "\(Auth.auth().currentUser?.displayName ?? "unknown")"
            ])
        var arraay = UserDefaults.standard.stringArray(forKey: "FlaggedPoll")
        arraay?.append(titleText)
        UserDefaults.standard.set(arraay, forKey: "FlaggedPoll")
        unexistIt(text: "You have flagged this poll")
    }
    @objc func respondsNo() { popUp.removeFromSuperview() }

    
    func deletePoll() {
        db.collection("Polls").document("\(self.titleText)").delete()
        self.removeFromSuperview()
    }
    
    func animate() {
        var cc = 0
        var ccc = 0
        votes.text = "Votes: \(Int(voters))"
        for view in self.subviews {
            if let sB = view as? specialButton {
                if sB.tag == self.chosenOpt {
                    sB.voteAmount = self.percentages[cc] + 1
                    sB.percentage = sB.voteAmount/self.voters
                    sB.checkVar = true
                } else {
                    sB.voteAmount = self.percentages[cc]
                    sB.percentage = sB.voteAmount/self.voters
                    sB.checkVar = true
                }
                cc+=1
                sB.animate()
            }
            if let sV = view as? UIScrollView {
                for vv in sV.subviews {
                    if let sB = vv as? specialButton {
                        if sB.tag == self.chosenOpt {
                            sB.voteAmount = self.percentages[ccc] + 1
                            sB.percentage = sB.voteAmount/self.voters
                            sB.checkVar = true
                        } else {
                            sB.voteAmount = self.percentages[ccc]
                            sB.percentage = sB.voteAmount/self.voters
                            sB.checkVar = true
                        }
                        ccc+=1
                        sB.animate()
                    }
                }
            }
        }
    }
    
    func updateView() {
        title.text = "\(titleText)"
        votes.text = "Votes: \(Int(voters))"
        person.text = "By: \(name)"
        title.originalText = titleText
        votes.originalText = "Votes: \(Int(voters))"
        person.originalText = "By: \(name)"
        title.censorText()
        votes.censorText()
        person.censorText()
        var bb = 0
        var bool = true
        while bool {
            var bbb = 0
            for key in keys {
                var keyer = key
                let keyt = keys[bbb]
                let optt = options[bbb]
                let pert = percentages[bbb]
                keyer = String(keyer.dropFirst())
                keyer = String(keyer.dropFirst())
                keyer = String(keyer.dropFirst())
                let keynnn = Int(keyer)!
                if keynnn == bb {
                    keys.remove(at: bbb)
                    keys.insert(keyt, at: bb)
                    options.remove(at: bbb)
                    options.insert(optt, at: bb)
                    percentages.remove(at: bbb)
                    percentages.insert(pert, at: bb)
                }
                bbb+=1
            }
            bb+=1
            if bb==keys.count {bool=false}
        }
    }
}
