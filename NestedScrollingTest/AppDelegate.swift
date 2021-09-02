//
//  AppDelegate.swift
//  NestedScrollingTest
//
//  Created by weichuang on 2021/9/2.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow()
        self.window?.frame = UIScreen.main.bounds
        self.window?.makeKeyAndVisible()
        UIApplication.shared.delegate?.window!!.rootViewController = OutScrollerViewController()
        return true
    }

}

