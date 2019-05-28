//
//  SignIn.swift
//  Settler
//
//  Created by Ever Time Cole on 10/10/18.
//  Copyright © 2018 Ever Time Cole. All rights reserved.
//

import Firebase
public var firstTime = true

class SignIn: UIViewController {

    let usernameField = UITextField()
    let passwordField = UITextField()
    let signInButton = UIButton()
    let createAccount = UIButton()
    let viewLabel = specialLabel()
    var agrees = Bool()
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameField.text = UserDefaults.standard.object(forKey: "Username") as? String
        passwordField.text = UserDefaults.standard.object(forKey: "Password") as? String
        if UserDefaults.standard.bool(forKey: "AgreesWithPolicy") == true && UserDefaults.standard.bool(forKey: "AgreesWithEULA") == true {
            agrees = true
        }
        if firstTime == true && agrees == true{
            firstTime = false
            self.bMethod(sender: self)
        }
        Analytics.setScreenName("Sign In", screenClass: "UIView")
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        self.view.backgroundColor = UIColor.white
        usernameField.frame = CGRect(x: self.view.frame.width*0.1, y: self.view.frame.height*0.12, width: self.view.frame.width*0.8, height: self.view.frame.height*0.11)
        passwordField.frame = CGRect(x: self.view.frame.width*0.1, y: self.view.frame.height*0.24, width: self.view.frame.width*0.8, height: self.view.frame.height*0.11)
        signInButton.frame = CGRect(x: self.view.frame.width*0.1, y: self.view.frame.height*0.36, width: self.view.frame.width*0.8, height: self.view.frame.height*0.11)
        createAccount.frame = CGRect(x: self.view.frame.width*0.1, y: self.view.frame.height*0.48, width: self.view.frame.width*0.8, height: self.view.frame.height*0.11)
        viewLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height*0.15)
        usernameField.borderStyle = UITextField.BorderStyle.roundedRect
        passwordField.borderStyle = UITextField.BorderStyle.roundedRect
        passwordField.isSecureTextEntry = true
        viewLabel.text = "Sign In"
        createAccount.setTitle("Account Creation Page", for: .normal)
        createAccount.setTitleColor(UIColor.black, for: .normal)
        createAccount.layer.cornerRadius = 8
        createAccount.layer.borderColor = UIColor.black.cgColor
        createAccount.layer.borderWidth = 2.0
        createAccount.addTarget(self, action: #selector(self.aMethod), for: .touchUpInside)
        let centeredParagraphStyle = NSMutableParagraphStyle()
        centeredParagraphStyle.alignment = .center
        let attributedPlaceholderEmail = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.paragraphStyle: centeredParagraphStyle, NSAttributedString.Key.font: UIFont(name: "Avenir-Light", size: 30)!])
        let attributedPlaceholderPassword = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.paragraphStyle: centeredParagraphStyle, NSAttributedString.Key.font: UIFont(name: "Avenir-Light", size: 30)!])
        usernameField.attributedPlaceholder = attributedPlaceholderEmail
        passwordField.attributedPlaceholder = attributedPlaceholderPassword
        usernameField.font = UIFont(name: "Avenir-Light", size: 20)
        passwordField.font = UIFont(name: "Avenir-Light", size: 20)
        usernameField.textAlignment = .center
        passwordField.textAlignment = .center
        signInButton.setTitle("Sign In", for: .normal)
        signInButton.setTitleColor(UIColor.black, for: .normal)
        signInButton.layer.cornerRadius = 8
        signInButton.layer.borderColor = UIColor.black.cgColor
        signInButton.layer.borderWidth = 2.0
        signInButton.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 23)
        createAccount.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 23)
        signInButton.addTarget(self, action: #selector(self.bMethod), for: .touchUpInside)
        self.view.addSubview(usernameField)
        self.view.addSubview(passwordField)
        self.view.addSubview(createAccount)
        self.view.addSubview(signInButton)
        self.view.addSubview(viewLabel)
        let lbbl = specialLabel(frame: CGRect(x: 0, y: self.view.frame.height*0.6, width: self.view.frame.width, height: self.view.frame.height*0.4))
        let lbblPoss = ["Hold down on a poll to report it", "Swipe left or right on any poll to get rid of it", "Tap on a recomendation under the search bar to search for it"]
        lbbl.text = lbblPoss[randomInt(min: 0, max: CGFloat(lbblPoss.count))]
        self.view.addSubview(lbbl)
        checkForPolicy(text: "EULA: \n If someone is purposely being abusive or objectionable to an individual or the community their account will be removed. Objectionable content includes but is not limited to: personal information, sexual content, and violent content. I reserve the right to remove accounts, content, and the ability to change this without warning.", type: "AgreesWithEULA")
        checkForPolicy(text: "Privacy Policy: \n All information given will be seen by everyone. Please note that we do not require any personal informtion. If you are not able to legally consent we ask that you get someone who can consent for you to agree. Any questions can be sent to settlerofarguments@gmail.com", type: "AgreesWithPolicy")
    }
    
    func checkForPolicy(text: String, type: String) {
        let popUp = UIView()
        if UserDefaults.standard.bool(forKey: type) == false {
            popUp.frame = CGRect(x: self.view.frame.width*0.05, y: self.view.frame.height*0.05, width: self.view.frame.width*0.9, height: self.view.frame.height*0.9)
            popUp.layer.borderWidth = 1
            popUp.layer.cornerRadius = self.view.frame.height*0.02
            popUp.backgroundColor = UIColor.white
            self.view.addSubview(popUp)
            let positive = specialLabel(frame: CGRect(x: 0, y: 0, width: popUp.frame.width, height: popUp.frame.height*0.9))
            popUp.addSubview(positive)
            let yes = UIButton(frame: CGRect(x: 0, y: popUp.frame.height*0.9, width: popUp.frame.width*0.5, height: popUp.frame.height*0.1))
            let yesLBL = specialLabel(frame: CGRect(x: popUp.frame.width*0.05, y: popUp.frame.height*0.91, width: popUp.frame.width*0.4, height: popUp.frame.height*0.08))
            let no = UIButton(frame: CGRect(x: popUp.frame.width*0.5, y: popUp.frame.height*0.9, width: popUp.frame.width*0.5, height: popUp.frame.height*0.1))
            let noLBL = specialLabel(frame: CGRect(x: popUp.frame.width*0.55, y: popUp.frame.height*0.91, width: popUp.frame.width*0.4, height: popUp.frame.height*0.08))
            positive.text = text
            yesLBL.text = "Agree"
            noLBL.text = "Disagree"
            yesLBL.layer.borderWidth = 1
            yesLBL.layer.cornerRadius = self.view.frame.height*0.02
            noLBL.layer.borderWidth = 1
            noLBL.layer.cornerRadius = self.view.frame.height*0.02
            popUp.addSubview(yes)
            popUp.addSubview(no)
            popUp.addSubview(yesLBL)
            popUp.addSubview(noLBL)
            if type == "AgreesWithPolicy" {
                yes.addTarget(self, action: #selector(dMethod(sender:)), for: .touchUpInside)
            } else {
                yes.addTarget(self, action: #selector(ddMethod(sender:)), for: .touchUpInside)
            }
            no.addTarget(self, action: #selector(eMethod(sender:)), for: .touchUpInside)
        }
    }
    
    @objc func dMethod(sender: AnyObject) {
        errorMessage(text: "Thank you for agreeing", view: self.view)
        UserDefaults.standard.set(true, forKey: "AgreesWithPolicy")
        if let view = sender as? UIButton {
            view.superview?.removeFromSuperview()
        }
    }
    @objc func ddMethod(sender: AnyObject) {
        errorMessage(text: "Thank you for agreeing", view: self.view)
        UserDefaults.standard.set(true, forKey: "AgreesWithEULA")
        if let view = sender as? UIButton {
            view.superview?.removeFromSuperview()
        }
    }

    @objc func eMethod(sender: AnyObject) {
        errorMessage(text: "You need to agree before using the app", view: self.view)
    }

    
    @objc func aMethod(sender: AnyObject) {
        self.present(CreateAccountView(), animated: true, completion: nil)
    }
    
    @objc func bMethod(sender: AnyObject) {
        if usernameField.hasText == true {
            if passwordField.hasText == true {
                Auth.auth().signIn(withEmail: "\(usernameField.text!)@settler.ios", password: passwordField.text!) { (user, error) in
                    if error?.localizedDescription != nil {
                        errorMessage(text: error?.localizedDescription ?? "why", view: self.view)
                    }
                    if user != nil {
                        UserDefaults.standard.set(self.usernameField.text, forKey: "Username")
                        UserDefaults.standard.set(self.passwordField.text, forKey: "Password")
                        self.present(TabBarViewController(), animated: true)
                    }
                }
            } else {
                errorMessage(text: "Please Input a Password", view: self.view)
            }
        } else {
            errorMessage(text: "Please Input a Username", view: self.view)
        }
    }
}
