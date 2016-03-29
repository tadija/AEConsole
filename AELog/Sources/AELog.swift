//
// AELog.swift
//
// Copyright (c) 2016 Marko Tadić <tadija@me.com> http://tadija.net
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

// MARK: - Top Level

/** 
    Writes the textual representations of current timestamp, thread name,
    file name, line number and function name into the standard output.
 
    You can optionally provide custom message to be added at the end of a log line.
 
    - NOTE: If `AELog` setting "Enabled" is set to "NO" this will do nothing.
 
    - parameter message: Custom text which will be added at the end of a log line
*/
public func aelog(message: Any = "", path: String = #file, line: Int = #line, function: String = #function) {
    let thread = NSThread.currentThread()
    AELog.sharedInstance.log(thread: thread, path: path, line: line, function: function, message: "\(message)")
}

// MARK: - AELog

/// Handles logging called from `aelog` top-level function.
public class AELog {
    
    // MARK: Properties
    
    private static let sharedInstance = AELog()
    private let settings = AELogSettings()
    private weak var delegate: AELogDelegate?
    
    // MARK: API

    /// Configures delegate for `AELog` singleton. Use this if you need additional functionality after each line of log.
    public class func launchWithDelegate(delegate: AELogDelegate) {
        AELog.sharedInstance.delegate = delegate
    }
    
    private func log(thread thread: NSThread, path: String, line: Int, function: String, message: String) {
        if settings.enabled {
            let file = fileNameForPath(path)
            if fileEnabled(file) {
                let logLine = AELogLine(thread: thread, file: file, line: line, function: function, message: message)
                print(logLine.description)
                delegate?.didLog(logLine)
            }
        }
    }
    
    // MARK: Helpers
    
    private func fileNameForPath(path: String) -> String {
        guard let
            fileName = NSURL(fileURLWithPath: path).URLByDeletingPathExtension?.lastPathComponent
        else { return "Unknown" }
        return fileName
    }
    
    private func fileEnabled(fileName: String) -> Bool {
        guard let
            files = settings.files,
            fileEnabled = files[fileName]
        else { return true }
        return fileEnabled
    }
    
}

// MARK: - AELogDelegate

/// Forwards logged lines via `didLog:` function.
public protocol AELogDelegate: class {
    func didLog(logLine: AELogLine)
}

// MARK: - AELogLine

/// Custom data structure used by `AELog` for log lines.
public struct AELogLine: CustomStringConvertible {
    
    // MARK: Properties
    
    private let timestamp: NSDate
    private let thread: NSThread
    private let file: String
    private let line: Int
    private let function: String
    private let message: String
    
    // MARK: - CustomStringConvertible
    
    /// Concatenated text representation of a complete log line
    public var description: String {
        let date = AELog.sharedInstance.settings.dateFormatter.stringFromDate(timestamp)
        let threadName = thread.isMainThread ? "Main" : (thread.name ?? "Unknown")
        let message = self.message == "" ? "" : " | \"\(self.message)\""
        let desc = "\(date) -- [\(threadName)] \(self.file) (\(self.line)) -> \(self.function)\(message)"
        return desc
    }
    
    // MARK: Init
    
    private init(thread: NSThread, file: String, line: Int, function: String, message: String) {
        self.timestamp = NSDate()
        self.thread = thread
        self.file = file
        self.line = line
        self.function = function
        self.message = message
    }
    
}

// MARK: - AELogSettings

/**
    Helper for accessing settings from the external file.
 
    Create `AELog.plist` dictionary file and add it to your target.
 
    There is `Key` struct which contains possible keys for all settings.
*/
public class AELogSettings {
    
    // MARK: Constants
    
    /// Setting keys which can be used in `AELog.plist` dictionary.
    public struct Key {
        /// Boolean - Logging enabled flag (defaults to `YES`)
        public static let Enabled = "Enabled"
        
        /// Dictionary - Key: file name without extension, Value: Boolean (defaults to empty - all files log enabled)
        public static let Files = "Files"
    }
    
    private struct Default {
        private static let Enabled = true
    }
    
    // MARK: Properties
    
    private let dateFormatter = NSDateFormatter()
    
    /// Contents of `AELog.plist` file
    public private(set) lazy var plist: [String : AnyObject]? = {
        guard let
            path = NSBundle.mainBundle().pathForResource("AELog", ofType: "plist"),
            settings = NSDictionary(contentsOfFile: path) as? [String : AnyObject]
        else { return nil }
        return settings
    }()
    
    // MARK: Init
    
    public init() {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    }
    
    // MARK: Settings
    
    private lazy var enabled: Bool = { [unowned self] in
        guard let
            settings = self.plist,
            enabled = settings[Key.Enabled] as? Bool
        else { return Default.Enabled }
        return enabled
    }()
    
    private lazy var files: [String : Bool]? = { [unowned self] in
        guard let
            settings = self.plist,
            files = settings[Key.Files] as? [String : Bool]
        else { return nil }
        return files
    }()
    
}
