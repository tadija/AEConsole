//
//  AELog.swift
//  TweetPlay
//
//  Created by Marko Tadic on 3/16/16.
//  Copyright © 2016 AE. All rights reserved.
//

import Foundation

func aelog(message: String = "", filePath: String = __FILE__, line: Int = __LINE__, function: String = __FUNCTION__) {
    var threadName = ""
    threadName = NSThread.currentThread().isMainThread ? "MAIN THREAD" : (NSThread.currentThread().name ?? "UNKNOWN THREAD")
    threadName = "[" + threadName + "] "
    
    let fileName = NSURL(fileURLWithPath: filePath).URLByDeletingPathExtension?.lastPathComponent ?? "???"
    
    var msg = ""
    if message != "" {
        msg = " - \(message)"
    }
    
    NSLog("-- " + threadName + fileName + "(\(line))" + " -> " + function + msg)
}