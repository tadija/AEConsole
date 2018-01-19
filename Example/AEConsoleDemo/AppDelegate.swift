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
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        /// - Note: Access Console settings
        let settings = Console.shared.settings

        /// - Note: Customize Console settings like this, these are defaults:
        settings.isShakeGestureEnabled = true
        settings.backColor = UIColor.black
        settings.textColor = UIColor.white
        settings.fontSize = 12.0
        settings.rowHeight = 14.0
        settings.opacity = 0.7

        /// - Note: Configure Console in app window (it's recommended to skip this for public release)
        Console.shared.configure(in: window)

        /// - Note: Add any log line manually (lines from AELog will automatically be added)
        Console.shared.addLogLine(line: "Hello!")

        /// - Note: Log something with AELog
        logToDebugger()

        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        logToDebugger()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        logToDebugger()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        logToDebugger()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        logToDebugger()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        logToDebugger()
    }

}
