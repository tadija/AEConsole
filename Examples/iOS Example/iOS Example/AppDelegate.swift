//
//  AppDelegate.swift
//  iOS Example
//
//  Created by Marko Tadic on 3/28/16.
//  Copyright © 2016 AE. All rights reserved.
//

import UIKit
import AEConsole

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        AEConsole.launchWithAppDelegate(self)
        aelog()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        aelog()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        aelog()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        aelog()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        aelog()
    }

    func applicationWillTerminate(application: UIApplication) {
        aelog()
    }

}
