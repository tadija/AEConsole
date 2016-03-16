//
//  AELog.swift
//  AELog
//
//  Created by Marko Tadic on 3/16/16.
//  Copyright © 2016 AE. All rights reserved.
//

import Foundation
import UIKit

func aelog(message: String = "", filePath: String = __FILE__, line: Int = __LINE__, function: String = __FUNCTION__) {
    AELog.sharedInstance.log(message, filePath: filePath, line: line, function: function)
}

public protocol AELogDelegate: class {
    func didLog(message: String)
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

extension AELogDelegate {
    
    func didLog(message: String) {
        print("didLog: \(message)")
        
        if let app = self as? AppDelegate {
            print("I'm app delegate")
            
            let textView = UITextView()
            textView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
            textView.textColor = UIColor.whiteColor()
            textView.text = message
            textView.frame = app.window!.bounds
            
            app.window?.addSubview(textView)
        }
    }
    
}