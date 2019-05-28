//
//  FirstViewController.swift
//  Settler
//
//  Created by Ever Time Cole on 10/10/18.
//  Copyright © 2018 Ever Time Cole. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Firebase

class TabBarViewController: UITabBarController, GADBannerViewDelegate {
    var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.tabBar.tintColor = UIColor.blue 
        self.tabBar.unselectedItemTintColor = UIColor.black
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        addBannerViewToView(bannerView)
        bannerView.delegate = self
        bannerView.adUnitID = "ca-app-pub-2732851918745448/4627387798"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        self.view.addSubview(tabBar)
        self.addChild(ProfileViewController())
        self.addChild(CreateViewController())
        self.addChild(HomeViewController())
        self.addChild(SearchViewController())
        self.addChild(SettingsViewController())
        self.selectedIndex = 0
        self.selectedIndex = 1
        self.selectedIndex = 2
        self.selectedIndex = 3
        self.selectedIndex = 4
        self.selectedIndex = 2
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: tabBar,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
}





func adViewDidReceiveAd(_ bannerView: GADBannerView) {
    bannerView.alpha = 0
    UIView.animate(withDuration: 1, animations: {
        bannerView.alpha = 1
    })
}
