//
//  SearchViewController.swift
//  Settler
//
//  Created by Ever Time Cole on 10/15/18.
//  Copyright © 2018 Ever Time Cole. All rights reserved.
//

import UIKit
import Firebase

class SearchViewController: UIViewController, UITextFieldDelegate {
    let searchField = UITextField()
    let db = Firestore.firestore()
    var returnedDocs:[String] = []
    let switcher = switcherView()
    var recomendations:[String] = []
    var howMany = 0
    var type = "Polls"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(cycleThroughPolls), name: NSNotification.Name(rawValue: goToNext), object: nil)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        self.tabBarItem = UITabBarItem(title: "Search", image: UIImage(named: "Search"), tag: 1)
        searchField.attributedPlaceholder = NSAttributedString.init(string: "Search for anything")
        searchField.frame = CGRect(x: self.view.frame.width*0.05, y: self.view.frame.height*0.03, width: self.view.frame.width*0.9, height: self.view.frame.height*0.07)
        searchField.borderStyle = .roundedRect
        self.view.addSubview(searchField)
        searchField.returnKeyType = .search
        searchField.delegate = self
        switcher.frame = CGRect(x: self.view.frame.width*0.1, y: self.view.frame.height*0.105, width: self.view.frame.width*0.8, height: self.view.frame.height*0.07)
        switcher.tag = 0
        searchField.tag = 0
        self.view.addSubview(switcher)
    }
    
    func updateRecomendations(bool: Bool, textField: UITextField) {
        recomendations.removeAll()
        if bool == true {type="Polls"} else {type="Users"}
        db.collection("Recommendations").document(type).getDocument { (document, error) in
            if let document = document, document.exists {
                for doc in document.data()! {
                    self.recomendations.append(doc.value as! String)
                    self.showRecomenations(textField: textField)
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func showRecomenations(textField: UITextField) {
        let recomendationView = UIView(frame: CGRect(x: textField.frame.minX, y: textField.frame.maxY, width: textField.frame.width, height: 0))
        recomendationView.tag = 54
        textField.superview?.addSubview(recomendationView)
        var stu = 0
        for _ in recomendations {
            let option = UIButton(frame: CGRect(x: 0, y: 0, width: textField.frame.width, height: 0))
            option.setTitle(recomendations[stu], for: .normal)
            option.layer.borderWidth = 3
            option.layer.backgroundColor = UIColor.black.cgColor
            option.titleLabel?.textColor = UIColor.black
            option.titleLabel?.font = UIFont(name: "Avenir-Light", size: 20)!
            option.tag=stu
            option.addTarget(self, action: #selector(chooseOption), for: .touchUpInside)
            recomendationView.addSubview(option)
            stu+=1
        }
        for view in self.view.subviews {
            if view.tag == 54 {
                UIView.animate(withDuration: 0.4, animations: {
                    view.frame = CGRect(x: textField.frame.minX, y: textField.frame.maxY, width: textField.frame.width, height: textField.frame.height*CGFloat(self.recomendations.count))
                    var stut = 0
                    for vi in view.subviews {
                        vi.frame = CGRect(x: 0, y: textField.frame.height*CGFloat(stut), width: textField.frame.width, height: textField.frame.height)
                        stut+=1
                    }
                })
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateRecomendations(bool: switcher.isOn, textField: textField)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        for view in self.view.subviews {
            if view.tag == 54 {
                UIView.animate(withDuration: 0.4, animations: {
                    view.frame = CGRect(x: view.frame.minX, y: view.frame.minY, width: view.frame.width, height: 0)
                    for vi in view.subviews {
                        vi.frame = CGRect(x: 0, y: 0, width: vi.frame.width, height: 0)
                    }
                }, completion: {(finished:Bool) in
                    view.removeFromSuperview()
                })
            }
        }
        search(text: searchField.text ?? "")
    }
    
    @objc func chooseOption(sender: AnyObject) {
        for view in self.view.subviews {
            if let vi = view as? UITextField {
                vi.text = recomendations[sender.tag]
                vi.resignFirstResponder()
            }
        }
    }
    
    func search(text: String) {
        returnedDocs.removeAll()
        howMany = 0
        for views in self.view.subviews {
            if views.tag == 3 {
                views.removeFromSuperview()
            }
        }
        if text != "" {
            let newText = text.lowercased()
            let objectFrame = CGRect(x: self.view.frame.width*0.05, y: self.view.frame.height*0.18, width: self.view.frame.width*0.9, height: self.view.frame.height*0.66)
            if switcher.isOn { type = "Polls" } else { type = "Users" }
            db.collection(type).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    errorMessage(text: "Error getting documents: \(err)", view: self.view)
                } else {
                    for doc in (querySnapshot?.documents)! {
                        if doc.documentID.lowercased().contains(newText) {
                            self.returnedDocs.append(doc.documentID)
                        }
                    }
                    if self.returnedDocs.count == 0 {
                        errorMessage(text: "No results for \(text) in \(self.type)", view: self.view)
                    } else {
                        var num = self.returnedDocs.count
                        if self.returnedDocs.count<2 {num=self.returnedDocs.count} else {num=2}
                        for _ in 1...num {
                            if self.type == "Polls" {
                                let objectUsed = Poll(frame: objectFrame)
                                objectUsed.titleText = self.returnedDocs[self.howMany]
                                objectUsed.swiped = true
                                self.view.addSubview(objectUsed)
                                objectUsed.tag = 3
                            } else {
                                let objectUsed = User(frame: objectFrame)
                                objectUsed.usersName = self.returnedDocs[self.howMany]
                                self.view.addSubview(objectUsed)
                                objectUsed.tag = 3
                            }
                            self.howMany+=1
                        }
                        errorMessage(text: "\(self.returnedDocs.count) results", view: self.view)
                    }
                    
                }
            }
        } else {
            errorMessage(text: "Please search for something", view: self.view)
        }
    }
    
    @objc func cycleThroughPolls() {
        if let view = self.view.subviews.reversed().first {
            if view.tag == 3 {
                view.tag = 37
                //animateViewAway(view: view, dir: dir)
                if returnedDocs.count > howMany {
                    let objectFrame = CGRect(x: self.view.frame.width*0.05, y: self.view.frame.height*0.18, width: self.view.frame.width*0.9, height: self.view.frame.height*0.66)
                    if type == "Polls" {
                        let objectUsed = Poll(frame: objectFrame)
                        objectUsed.swiped = true
                        objectUsed.titleText = self.returnedDocs[self.howMany]
                        var last = UIView()
                        for viewT in self.view.subviews {
                            if viewT.tag == 3 {
                                last = viewT
                            }
                        }
                        self.view.insertSubview(objectUsed, belowSubview: last)
                        objectUsed.tag = 3
                    } else {
                        let objectUsed = User(frame: objectFrame)
                        objectUsed.usersName = self.returnedDocs[self.howMany]
                        var last = UIView()
                        for viewT in self.view.subviews {
                            if viewT.tag == 3 {
                                last = viewT
                            }
                        }
                        self.view.insertSubview(objectUsed, belowSubview: last)
                        objectUsed.tag = 3
                    }
                    howMany+=1
                }
            }
        }
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: goToNext), object: self)
    }

}
