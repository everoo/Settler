//
//  random.swift
//  Settler
//
//  Created by Ever Time Cole on 10/21/18.
//  Copyright © 2018 Ever Time Cole. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
}

func random(min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
}

func randomInt(min: CGFloat, max: CGFloat) -> Int {
    return Int(random() * (max - min) + min)
}

func censor(string: String) -> String {
    var returnedStr = string
    var places:[Int] = []
    var place = 0
    for char in string {
        if "\(char)" == "\(char)".capitalized {
            places.append(place)
        }
        place += 1
    }
    for word in UserDefaults.standard.stringArray(forKey: "BadWords") ?? [""] {
        var amnt = ""
        for char in word { if char == " " { amnt.append(" ") } else { amnt.append("*") } }
        returnedStr = returnedStr.lowercased().replacingOccurrences(of: word.lowercased(), with: amnt)
    }
    var tester:[String] = []
    for char in returnedStr {
        tester.append("\(char)")
    }
    for plac in places {
        tester[plac] = tester[plac].capitalized
    }
    returnedStr.removeAll()
    for char in tester {
        returnedStr.append(char)
    }
    return returnedStr
}

func animateViewAway(view: UIView, dir: CGFloat) {
    let randT = Double(random(min: 0.25, max: 0.45))
    let randY = random(min: -100, max: 200)
    let randR = random(min: -20, max: 20)
    UIView.animate(withDuration: 0.04, animations: {
        view.center.x -= 15*dir
        view.transform = CGAffineTransform(rotationAngle: (dir * 3.0 * .pi) / 180.0)
    }, completion: {(finished:Bool) in
        UIView.animate(withDuration: randT, delay: 0, options: .curveEaseOut, animations: {
            view.center.x -= (500*dir)
            view.center.y -= randY
            view.transform = CGAffineTransform(rotationAngle: (dir*150.0+randR*dir * .pi) / 180.0)
            view.alpha = 0.8
        }, completion: {(finished:Bool) in
            view.removeFromSuperview()
        })
    })
}

