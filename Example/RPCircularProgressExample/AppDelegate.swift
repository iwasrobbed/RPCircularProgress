//
//  AppDelegate.swift
//  RPCircularProgressExample
//
//  Created by Rob Phillips on 4/5/16.
//  Copyright © 2016 Glazed Donut, LLC. All rights reserved.
//
//  See LICENSE for full license agreement.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        setupRootView()

        return true
    }

    fileprivate func setupRootView() {
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
    }
}

