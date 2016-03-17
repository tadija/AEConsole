//
//  AELog.swift
//  AELog
//
//  Created by Marko Tadic on 3/16/16.
//  Copyright © 2016 AE. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Top Level

public func log(message: String = "", path: String = __FILE__, line: Int = __LINE__, function: String = __FUNCTION__) {
    AELog.sharedInstance.log(message, path: path, line: line, function: function)
}

// MARK: - AELogDelegate

public protocol AELogDelegate: class {
    func didLog(message: String)
}

extension AELogDelegate where Self: AppDelegate {
    
    func didLog(message: String) {
        guard let window = self.window else { return }
        let logView = AELog.sharedInstance.logView
        logView.text += "\(message)\n"
        window.bringSubviewToFront(logView)
        logView.becomeFirstResponder()
    }
    
}

// MARK: - AELog

public class AELog {
    
    private struct Key {
        static let ClassName = NSStringFromClass(AELog).componentsSeparatedByString(".").last!
        static let Enabled = "Enabled"
    }
    
    // MARK: - Singleton
    
    public static let sharedInstance = AELog()
    
    public class func launchWithDelegate(delegate: AELogDelegate, settingsPath: String? = nil) {
        AELog.sharedInstance.delegate = delegate
        AELog.sharedInstance.settingsPath = settingsPath
    }
    
    // MARK: - Properties
    
    private let logView = LogView()
    
    public weak var delegate: AELogDelegate? {
        didSet {
            addLogViewToAppWindow()
        }
    }
    
    public var settingsPath: String?
    
    // MARK: - Helpers
    
    private func addLogViewToAppWindow() {
        guard let
            app = delegate as? AppDelegate,
            window = app.window
        else { return }
        
        logView.frame = window.bounds
        logView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        window.addSubview(logView)
    }
    
    private var infoPlist: NSDictionary? {
        guard let
            path = NSBundle.mainBundle().pathForResource("Info", ofType: "plist"),
            info = NSDictionary(contentsOfFile: path)
        else { return nil }
        return info
    }
    
    private var logSettings: [String : AnyObject]? {
        if let path = settingsPath {
            return settingsForPath(path)
        } else if let path = NSBundle.mainBundle().pathForResource(Key.ClassName, ofType: "plist") {
            return settingsForPath(path)
        } else {
            guard let
                info = infoPlist,
                settings = info[Key.ClassName] as? [String : AnyObject]
            else { return nil }
            return settings
        }
    }
    
    private func settingsForPath(path: String?) -> [String : AnyObject]? {
        guard let
            path = path,
            settings = NSDictionary(contentsOfFile: path) as? [String : AnyObject]
        else { return nil }
        return settings
    }
    
    private var logEnabled: Bool {
        guard let
            settings = logSettings,
            enabled = settings[Key.Enabled] as? Bool
        else { return false }
        return enabled
    }
    
    // MARK: - Actions
    
    private func log(message: String = "", path: String = __FILE__, line: Int = __LINE__, function: String = __FUNCTION__) {
        if logEnabled {
            let logString = generateLogString(message: message, path: path, line: line, function: function)
            NSLog(logString)
            delegate?.didLog(logString)
        }
    }
    
    private func generateLogString(message message: String, path: String, line: Int, function: String) -> String {
        let fileName = fileNameForPath(path)
        let logMessage = message == "" ? "" : " - \(message)"
        let logString = "-- [\(threadName)] \(fileName) (\(line)) -> \(function)\(logMessage)"
        return logString
    }
    
    private var threadName: String {
        let thread = NSThread.currentThread()
        let name = thread.isMainThread ? "Main" : (thread.name ?? "Unknown")
        return name
    }
    
    private func fileNameForPath(path: String) -> String {
        guard let
            fileName = NSURL(fileURLWithPath: path).URLByDeletingPathExtension?.lastPathComponent
        else { return "Unknown" }
        return fileName
    }
    
}

// MARK: - LogView

class LogView: UIView {
    
    // MARK: - Outlets
    
    private let textView = UITextView()
    private let `switch` = UISwitch()
    private let clearButton = UIButton()
    
    // MARK: - Properties
    
    var text = "" {
        didSet {
            textView.text = text
            scrollToBottom()
        }
    }
    
    private func scrollToBottom() {
        let contentHeight = textView.contentSize.height
        let shouldScroll = contentHeight > bounds.height
        if shouldScroll {
            let bottomOffset = CGPoint(x: 0, y: contentHeight)
            textView.setContentOffset(bottomOffset, animated: false)
        }
    }
    
    private var shouldForwardTouches = false
    
    // MARK: - Init
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        configureUI()
    }
    
    private func configureUI() {
        configureOutlets()
        configureLayout()
    }
    
    private func configureOutlets() {
        textView.editable = false
        textView.selectable = false
        textView.alwaysBounceVertical = true
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 0, right: 0)
        textView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
        textView.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.7)
        
        `switch`.on = true
        `switch`.addTarget(self, action: Selector("switchValueChanged:"), forControlEvents: .ValueChanged)
        
        clearButton.setTitle("Clear", forState: .Normal)
        clearButton.addTarget(self, action: Selector("clearButtonTapped:"), forControlEvents: .TouchUpInside)
    }
    
    // MARK: - Actions
    
    func switchValueChanged(sender: UISwitch) {
        shouldForwardTouches = !sender.on
        clearButton.hidden = !sender.on
    }
    
    func clearButtonTapped(sender: UIButton) {
        text = ""
    }
    
    // MARK: - Layout
    
    private func configureLayout() {
        addSubview(textView)
        addSubview(`switch`)
        addSubview(clearButton)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        `switch`.translatesAutoresizingMaskIntoConstraints = false
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        
        configureTextViewConstraints()
        configureSwitchConstraints()
        configureClearButtonConstraints()
    }
    
    private func configureTextViewConstraints() {
        guard let textViewConstraints = textViewConstraints else { return }
        NSLayoutConstraint.activateConstraints(textViewConstraints)
    }
    
    private func configureSwitchConstraints() {
        guard let switchConstraints = switchConstraints else { return }
        NSLayoutConstraint.activateConstraints(switchConstraints)
    }
    
    private func configureClearButtonConstraints() {
        guard let clearButtonConstraints = clearButtonConstraints else { return }
        NSLayoutConstraint.activateConstraints(clearButtonConstraints)
    }
    
    private var textViewConstraints: [NSLayoutConstraint]? {
        guard let
            leading = textView.leadingAnchor.constraintEqualToAnchor(leadingAnchor),
            trailing = textView.trailingAnchor.constraintEqualToAnchor(trailingAnchor),
            top = textView.topAnchor.constraintEqualToAnchor(topAnchor),
            bottom = textView.bottomAnchor.constraintEqualToAnchor(bottomAnchor)
            else { return nil }
        return [leading, trailing, top, bottom]
    }
    
    private var switchConstraints: [NSLayoutConstraint]? {
        guard let
            centerX = `switch`.centerXAnchor.constraintEqualToAnchor(centerXAnchor),
            centerY = `switch`.centerYAnchor.constraintEqualToAnchor(centerYAnchor)
            else { return nil }
        return [centerX, centerY]
    }
    
    private var clearButtonConstraints: [NSLayoutConstraint]? {
        guard let
            centerX = clearButton.centerXAnchor.constraintEqualToAnchor(centerXAnchor, constant: 100.0),
            centerY = clearButton.centerYAnchor.constraintEqualToAnchor(centerYAnchor)
            else { return nil }
        return [centerX, centerY]
    }
    
    // MARK: - Override
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, withEvent: event)
        
        if hitView == textView && shouldForwardTouches {
            return nil
        }
        
        return hitView
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            UIView.transitionWithView(self, duration: 0.3, options: .TransitionCrossDissolve, animations: { () -> Void in
                self.hidden = !self.hidden
                }, completion: nil)
        }
    }
    
}
