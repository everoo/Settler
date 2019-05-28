//
//  HomeViewController.swift
//  Settler
//
//  Created by Ever Time Cole on 10/15/18.
//  Copyright © 2018 Ever Time Cole. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController, UIScrollViewDelegate {
    let db = Firestore.firestore()
    var docIDS:[String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 0.7, green: 0.8, blue: 1, alpha: 1)
        self.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "Home"), tag: 2)
        loadData()
        NotificationCenter.default.addObserver(self, selector: #selector(cycleThroughPolls), name: NSNotification.Name(rawValue: goToNext), object: nil)
    }
    
    func loadData() {
        db.collection("Polls").getDocuments() { (querySnapshot, err) in
            if let err = err {
                errorMessage(text: "Error getting documents: \(err)", view: self.view)
            } else {
                for doc in (querySnapshot?.documents)! {
                    self.docIDS.append(doc.documentID)
                }
                for _ in 1...6 {
                    let poll = Poll(frame: CGRect(x: self.view.frame.width*0.025, y: self.view.frame.height*0.03, width: self.view.frame.width*0.95, height: self.view.frame.height*0.815))
                    poll.titleText = "\(self.docIDS[randomInt(min: 0, max: CGFloat(self.docIDS.count))])"
                    self.view.addSubview(poll)
                }
            }
        }
    }
    
    @objc func cycleThroughPolls() {
        let poll = Poll(frame: CGRect(x: self.view.frame.width*0.025, y: self.view.frame.height*0.03, width: self.view.frame.width*0.95, height: self.view.frame.height*0.815))
        poll.titleText = "\(docIDS[randomInt(min: 0, max: CGFloat(docIDS.count))])"
        self.view.addSubview(poll)
        self.view.sendSubviewToBack(poll)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: goToNext), object: self)
    }

}
