/**
 *  https://github.com/tadija/AEConsole
 *  Copyright (c) Marko Tadić 2016-2019
 *  Licensed under the MIT license. See LICENSE file.
 */

import UIKit
import AEConsole

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        /// - Note: Access Console settings
        let settings = Console.shared.settings

        /// - Note: Customize Console settings like this, these are defaults:
        settings.isShakeGestureEnabled = true
        settings.backColor = UIColor.black
        settings.textColor = UIColor.white
        settings.fontSize = 12.0
        settings.rowSpacing = 4.0
        settings.opacity = 0.7

        /// - Note: Configure Console in app window (it's recommended to skip this for public release)
        Console.shared.configure(in: window)

        /// - Note: Add any log line manually (lines from AELog will automatically be added)
        Console.shared.addLogLine(line: "Hello!\n")

        /// - Note: Log something with AELog
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
        let text =  """
        \n
        > Calling Console.shared.configure(in: window) will add Console.View
        > as a subview to your App's window and make it hidden by default.
        > Whenever you need Console UI, you just make a shake gesture and it's there!
        > When you no longer need it, shake again and it's gone.
        > The rest is up to AELog's logging functionality.
        > Whatever is logged with it, will show up in Console.View.
        """
        aelog(text)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        aelog()
    }

}
