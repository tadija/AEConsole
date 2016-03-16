//
//  AELog.swift
//  AELog
//
//  Created by Marko Tadic on 3/16/16.
//  Copyright © 2016 AE. All rights reserved.
//

import Foundation
import UIKit

public func aelog(message: String = "", filePath: String = __FILE__, line: Int = __LINE__, function: String = __FUNCTION__) {
    AELog.sharedInstance.log(message, filePath: filePath, line: line, function: function)
}

public class AELog {
    
    // MARK: - Singleton
    
    public static let sharedInstance = AELog()
    
    // MARK: - Properties
    
    public weak var delegate: AELogDelegate?
    
    private var infoPlist: NSDictionary? {
        guard let
            path = NSBundle.mainBundle().pathForResource("Info", ofType: "plist"),
            info = NSDictionary(contentsOfFile: path)
        else { return nil }
        return info
    }
    
    private var logSettings: [String : AnyObject]? {
        guard let
            info = infoPlist,
            settings = info["AELog"] as? [String : AnyObject]
            else { return nil }
        return settings
    }
    
    private var logEnabled: Bool {
        guard let
            settings = logSettings,
            enabled = settings["Enabled"] as? Bool
        else { return false }
        return enabled
    }
    
    // MARK: - Actions
    
    private func log(message: String = "", filePath: String = __FILE__, line: Int = __LINE__, function: String = __FUNCTION__) {
        if logEnabled {
            var threadName = ""
            threadName = NSThread.currentThread().isMainThread ? "MAIN THREAD" : (NSThread.currentThread().name ?? "UNKNOWN THREAD")
            threadName = "[" + threadName + "] "
            
            let fileName = NSURL(fileURLWithPath: filePath).URLByDeletingPathExtension?.lastPathComponent ?? "???"
            
            var msg = ""
            if message != "" {
                msg = " - \(message)"
            }
            
            NSLog("-- " + threadName + fileName + "(\(line))" + " -> " + function + msg)
            
            delegate?.didLog(message)
        }
    }
    
}

public protocol AELogDelegate: class {
    func didLog(message: String)
}

extension AELogDelegate where Self: AppDelegate {
    
    func didLog(message: String) {
        if let window = self.window {
            let textView = UITextView()
            textView.frame = window.bounds
            textView.userInteractionEnabled = false
            textView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
            textView.textColor = UIColor.whiteColor()
            textView.text = message
            window.addSubview(textView)
        }
    }
    
}