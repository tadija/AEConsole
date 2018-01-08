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
        Console.launch(with: self)
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
