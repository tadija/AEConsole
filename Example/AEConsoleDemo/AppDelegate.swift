//
//  AppDelegate.swift
//  AEConsoleDemo
//
//  Created by Marko Tadic on 4/1/16.
//  Copyright © 2016 AE. All rights reserved.
//

import UIKit
import AEConsole

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        AEConsole.launch(with: self)
        aelog()
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        aelog()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        aelog()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        aelog()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        aelog()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        aelog()
    }

}
