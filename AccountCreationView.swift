//
//  AccountCreationView.swift
//  Settler
//
//  Created by Ever Time Cole on 10/11/18.
//  Copyright © 2018 Ever Time Cole. All rights reserved.
//

import Firebase

class CreateAccountView: UIViewController {
    let db = Firestore.firestore()

    let usernameField = UITextField()
    let passwordField = UITextField()
    let createAccount = UIButton()
    let signInPage = UIButton()
    let viewLabel = specialLabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameField.frame = CGRect(x: self.view.frame.width*0.1, y: self.view.frame.height*0.12, width: self.view.frame.width*0.8, height: self.view.frame.height*0.11)
        passwordField.frame = CGRect(x: self.view.frame.width*0.1, y: self.view.frame.height*0.24, width: self.view.frame.width*0.8, height: self.view.frame.height*0.11)
        createAccount.frame = CGRect(x: self.view.frame.width*0.1, y: self.view.frame.height*0.36, width: self.view.frame.width*0.8, height: self.view.frame.height*0.11)
        signInPage.frame = CGRect(x: self.view.frame.width*0.1, y: self.view.frame.height*0.48, width: self.view.frame.width*0.8, height: self.view.frame.height*0.11)
        viewLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height*0.15)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        self.view.backgroundColor = UIColor.white
        usernameField.borderStyle = UITextField.BorderStyle.roundedRect
        passwordField.borderStyle = UITextField.BorderStyle.roundedRect
        viewLabel.text = "Create a New Account"
        viewLabel.textAlignment = NSTextAlignment.center
        createAccount.setTitle("Create Your Account", for: .normal)
        createAccount.setTitleColor(UIColor.black, for: .normal)
        createAccount.tintColor = UIColor.blue
        createAccount.layer.cornerRadius = 8
        createAccount.layer.borderColor = UIColor.black.cgColor
        createAccount.layer.backgroundColor = UIColor.white.cgColor
        createAccount.layer.borderWidth = 2.0
        createAccount.addTarget(self, action: #selector(self.aMethod), for: .touchUpInside)
        let centeredParagraphStyle = NSMutableParagraphStyle()
        centeredParagraphStyle.alignment = .center
        let attributedPlaceholderPassword = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.paragraphStyle: centeredParagraphStyle, NSAttributedString.Key.font: UIFont(name: "Avenir-Light", size: 20)!])
        let attributedPlaceholderUser = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.paragraphStyle: centeredParagraphStyle, NSAttributedString.Key.font: UIFont(name: "Avenir-Light", size: 20)!])
        usernameField.attributedPlaceholder = attributedPlaceholderUser
        passwordField.attributedPlaceholder = attributedPlaceholderPassword
        usernameField.font = UIFont(name: "Avenir-Light", size: 20)
        passwordField.font = UIFont(name: "Avenir-Light", size: 20)
        usernameField.textAlignment = .center
        passwordField.textAlignment = .center
        passwordField.isSecureTextEntry = true
        signInPage.setTitle("Sign In Page", for: .normal)
        signInPage.setTitleColor(UIColor.black, for: .normal)
        signInPage.tintColor = UIColor.blue
        signInPage.layer.cornerRadius = 8
        signInPage.layer.borderColor = UIColor.black.cgColor
        signInPage.layer.backgroundColor = UIColor.white.cgColor
        signInPage.layer.borderWidth = 2.0
        signInPage.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 23)
        createAccount.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 23)
        signInPage.addTarget(self, action: #selector(self.bMethod), for: .touchUpInside)
        self.view.addSubview(usernameField)
        self.view.addSubview(passwordField)
        self.view.addSubview(createAccount)
        self.view.addSubview(signInPage)
        self.view.addSubview(viewLabel)

    }
    
    
    
    @objc func aMethod(sender: AnyObject) {
            if passwordField.hasText == true {
                if usernameField.hasText == true {
                    Auth.auth().createUser(withEmail: "\(usernameField.text!)@settler.ios", password: passwordField.text!) { (authResult, error) in
                        guard (authResult?.user) != nil else {
                            if (error?.localizedDescription.description)! == "The email address is already in use by another account" {
                                errorMessage(text: "That username is already taken", view: self.view)
                            } else {
                                errorMessage(text: (error?.localizedDescription.description)!, view: self.view)
                            }
                            return
                        }
                        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                        changeRequest?.displayName = self.usernameField.text
                        changeRequest?.commitChanges { error in
                            if let error = error { errorMessage(text: error.localizedDescription, view: self.view) }
                        }
                        UserDefaults.standard.set(self.usernameField.text, forKey: "Username")
                        UserDefaults.standard.set(self.passwordField.text, forKey: "Password")
                        UserDefaults.standard.set([""], forKey: "FlaggedUser")
                        UserDefaults.standard.set([""], forKey: "FlaggedPoll")
                        firstTime = true
                        self.present(SignIn(), animated: true, completion: nil)
                        self.db.collection("Users").document(self.usernameField.text!).setData(["a1D6FrGtwoNineEle1":0])
                    }
                } else {
                    errorMessage(text: "Please Input a Username", view: self.view)
                }
            } else {
                errorMessage(text: "Please Input a Password", view: self.view)
            }
    }
    
    @objc func bMethod(sender: AnyObject) {
        self.present(SignIn(), animated: true, completion: nil)
    }
}
