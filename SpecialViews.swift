//
//  SpecialViews.swift
//  Settler
//
//  Created by Ever Time Cole on 12/16/18.
//  Copyright © 2018 Ever Time Cole. All rights reserved.
//

import Foundation
import UIKit

class specialButton: UIButton {
    let BG = UIView()
    let lbl = specialLabel()
    var text = String()
    var percentage = CGFloat()
    var voteAmount = CGFloat()
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.layer.cornerRadius = self.frame.width*0.05
        lbl.layer.cornerRadius = self.frame.width*0.05
        BG.layer.cornerRadius = self.frame.width*0.05
        lbl.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        lbl.text = text
        self.backgroundColor = UIColor.white
        BG.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        BG.layer.backgroundColor = UIColor(red: 1, green: 0.7, blue: 0.7, alpha: 1).cgColor
        BG.isUserInteractionEnabled = false
        lbl.isUserInteractionEnabled = false
        self.addSubview(BG)
        self.addSubview(lbl)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.somethin(_:))))
    }
    
    
    @objc func somethin(_ tapGesture: UITapGestureRecognizer) {
        self.switchMode(sender: self, location: tapGesture.location(in: self))
    }
    
    var checkVar = false
    @objc func switchMode(sender: UIButton, location: CGPoint) {
        if checkVar == false {
            checkVar = true
            if let view = superview as? Poll {
                view.chosenOpt = sender.tag
                view.vote()
            }
            if let view = superview as? UIScrollView {
                if let viewfo = view.superview as? Poll {
                    viewfo.chosenOpt = sender.tag
                    viewfo.vote()
                }
            }
            let circle = UIView(frame: CGRect(x: location.x-10, y: location.y-10, width: 20, height: 20))
            circle.layer.cornerRadius = 10
            circle.layer.backgroundColor = UIColor.white.cgColor
            self.addSubview(circle)
            UIView.animate(withDuration: 0.5, animations: {
                circle.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
                circle.layer.cornerRadius = self.frame.width*0.05
                circle.alpha = 0
            }, completion: {(finished:Bool) in
                circle.removeFromSuperview()
            })
        }
    }
    

    func animate() {
        self.lbl.text = text
        self.lbl.censorText()
        let votes = specialLabel(frame: CGRect(x: self.frame.width*0.25, y: self.frame.height*0.25, width: self.frame.width*0.5, height: self.frame.height*0.5))
        votes.text = "\(Double(round(10*(self.percentage*100))/10))% - \(Int(Double(round(self.voteAmount))))"
        votes.layer.cornerRadius = self.frame.width*0.05
        votes.layer.backgroundColor = UIColor(red: 0.8, green: 0.2, blue: 0.7, alpha: 1).cgColor
        votes.alpha = 0
        self.addSubview(votes)
        UIView.animate(withDuration: Double((1-self.percentage)*0.6), delay: 0, options: .curveEaseOut, animations: {
            self.BG.frame = CGRect(x: 0, y: 0, width: self.frame.width*self.percentage, height: self.frame.height)
            self.BG.backgroundColor = UIColor(red: 1, green: 0.7, blue: 0.7, alpha: 0.5+self.percentage/2)
        })
        UIView.animate(withDuration: 3, delay: 0, options: [.repeat, .autoreverse, .curveEaseInOut], animations: {
            UIView.animate(withDuration: 1, animations: {
                votes.alpha = 0
            })
            votes.alpha = 1
        })
    }
    
}

let updateCens = "updateCensor"

class specialLabel: UILabel {
    var originalText = String()
    var places:[Int] = []
    override func didMoveToSuperview() {
        self.font = UIFont(name: "Avenir-Light", size: 24)!
        self.minimumScaleFactor = 0.3
        self.adjustsFontSizeToFitWidth = true
        self.numberOfLines = 15
        self.textAlignment = .center
        originalText = self.text ?? ""
        self.censorText()
        NotificationCenter.default.addObserver(self, selector: #selector(updateCensor), name: NSNotification.Name(rawValue: updateCens), object: nil)
    }
    
    @objc func updateCensor() {
        self.text = originalText
        self.text = censor(string: self.text ?? "")
    }
    
    func censorText() {
        self.text = originalText
        self.text = censor(string: self.text ?? "")
    }
    
    func uncensorText() {
        self.text = originalText
    }
    
}


class specialTextView: UITextView {
    override func didMoveToSuperview() {
        self.backgroundColor = UIColor.white
        self.font = UIFont(name: "Avenir-Light", size: 20)
        self.textAlignment = .center
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = self.frame.height*0.2
        self.censorText()
    }
    func censorText() {
        self.text = censor(string: self.text ?? "")
    }
}

var errors:CGFloat = -1
func errorMessage(text: String, view: UIView) {
    errors += 1
    let label1 = specialLabel(frame: CGRect(x: view.frame.width*0.1, y: view.frame.height*0.1+(view.frame.height*0.21*errors), width: view.frame.width*0.8, height: view.frame.height*0.2))
    label1.text = text
    label1.drawText(in: CGRect(x: label1.frame.width*0.05, y: label1.frame.height*0.05, width: label1.frame.width*0.9, height: label1.frame.height*0.9))
    label1.layer.backgroundColor = UIColor.init(red: 0.95, green: 0.95, blue: 0.95, alpha: 1).cgColor
    label1.layer.cornerRadius = 15
    label1.isUserInteractionEnabled = false
    view.addSubview(label1)
    UIView.animate(withDuration: 1.25, delay: 0, options: .curveEaseIn, animations: {
        label1.alpha = 0
    }) { _ in
        label1.removeFromSuperview()
        errors -= 1
    }
}

class switcherView: UIView {
    let button1 = UIButton()
    let button2 = UIButton()
    let selectView = UIView()
    var isOn = true
    let lbl1 = specialLabel()
    let lbl2 = specialLabel()

    override func didMoveToSuperview() {
        layer.cornerRadius = frame.height/2
        layer.borderWidth = self.frame.height*0.01
        button1.frame = CGRect(x: 0, y: 0, width: self.frame.width*0.5, height: self.frame.height)
        button2.frame = CGRect(x: self.frame.width*0.5, y: 0, width: self.frame.width*0.5, height: self.frame.height)
        lbl1.frame = CGRect(x: 0, y: 0, width: self.frame.width*0.5, height: self.frame.height)
        lbl2.frame = CGRect(x: self.frame.width*0.5, y: 0, width: self.frame.width*0.5, height: self.frame.height)
        button1.addTarget(self, action: #selector(userTrue), for: .touchUpInside)
        button2.addTarget(self, action: #selector(pollTrue), for: .touchUpInside)
        lbl1.text = "Users"
        lbl2.text = "Polls"
        selectView.frame = CGRect(x: self.frame.width*0.5-self.frame.height/2, y: 0, width: self.frame.height, height: self.frame.height)
        selectView.layer.cornerRadius = self.frame.height/2
        selectView.backgroundColor = UIColor(red: 0.8, green: 0.2, blue: 0.7, alpha: 1)
        selectView.isUserInteractionEnabled = false
        lbl1.isUserInteractionEnabled = false
        lbl2.isUserInteractionEnabled = false
        addSubview(button1)
        addSubview(button2)
        addSubview(selectView)
        addSubview(lbl1)
        addSubview(lbl2)
        animateToSide(bool: true)
    }
    
    @objc func userTrue() { if isOn==true {animateToSide(bool: false)}; isOn=false }
    @objc func pollTrue() { if isOn==false {animateToSide(bool: true)}; isOn=true }

    func animateToSide(bool: Bool) {
        UIView.animate(withDuration: 0.1, animations: {
            self.selectView.frame = CGRect(x: self.frame.width*0.5-self.frame.height/2, y: 0, width: self.frame.height, height: self.frame.height)
        }, completion: {(finished:Bool) in
            UIView.animate(withDuration: 0.1, animations: {
                if bool {
                    self.selectView.frame = CGRect(x: self.frame.width*0.5-self.frame.height/2, y: 0, width: self.frame.width*0.5+self.frame.height/2, height: self.frame.height)
                } else {
                    self.selectView.frame = CGRect(x: 0, y: 0, width: self.frame.width*0.5+self.frame.height/2, height: self.frame.height)
                }
            })
        })
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
        })
    }
}

func shakeView(view: UIView, dirt: CGFloat){
    var dir:CGFloat = 0
    if dirt>0 {dir = 1} else {dir = -1}
    UIView.animate(withDuration: 0.05, animations: {
        view.center.x -= 15*dir
        view.transform = CGAffineTransform(rotationAngle: (dir * 3.0 * .pi) / 180.0)
    }, completion: {(finished:Bool) in
        UIView.animate(withDuration: 0.05, animations: {
            view.center.x += 30*dir
            view.transform = CGAffineTransform(rotationAngle: (dir * -3.0 * .pi) / 180.0)
        }, completion: {(finished:Bool) in
            UIView.animate(withDuration: 0.05, animations: {
                view.center.x -= 30*dir
                view.transform = CGAffineTransform(rotationAngle: (dir * 3.0 * .pi) / 180.0)
            }, completion: {(finished:Bool) in
                UIView.animate(withDuration: 0.05, animations: {
                    view.center.x += 15*dir
                    view.transform = CGAffineTransform(rotationAngle: 0)
                })
            })
        })
    })
}
