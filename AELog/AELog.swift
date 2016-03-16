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
    
    static let sharedInstance = AELog()
    
    // MARK: - Properties
    
    weak var delegate: AELogDelegate?
    
    // MARK: - Actions
    
    func log(message: String = "", filePath: String = __FILE__, line: Int = __LINE__, function: String = __FUNCTION__) {
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