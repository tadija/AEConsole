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

public func log(message: Any = "", path: String = __FILE__, line: Int = __LINE__, function: String = __FUNCTION__) {
    AELog.sharedInstance.log(text: "\(message)", path: path, line: line, function: function)
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
        static let Name = NSStringFromClass(AELog).componentsSeparatedByString(".").last!
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
        } else if let path = NSBundle.mainBundle().pathForResource(Key.Name, ofType: "plist") {
            return settingsForPath(path)
        } else {
            guard let
                info = infoPlist,
                settings = info[Key.Name] as? [String : AnyObject]
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
    
    private func log(text text: String, path: String, line: Int, function: String) {
        if logEnabled {
            let logText = generateLogText(text, path: path, line: line, function: function)
            NSLog(logText)
            delegate?.didLog(logText)
        }
    }
    
    private func generateLogText(text: String, path: String, line: Int, function: String) -> String {
        let fileName = fileNameForPath(path)
        let message = text == "" ? "" : " | \"\(text)\""
        let logText = "-- [\(threadName)] \(fileName) (\(line)) -> \(function)\(message)"
        return logText
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
    
    private let scrollView = UIScrollView()
    private let textView = UITextView()
    
    private let toolbar = UIView()
    private let toolbarStack = UIStackView()
    private var toolbarLeadingConstraint: NSLayoutConstraint!
    
    private let settingsButton = UIButton()
    private let touchButton = UIButton()
    private let followButton = UIButton()
    private let clearButton = UIButton()
    
    private let closeGesture = UITapGestureRecognizer()
    
    // MARK: - Properties
    
    var text = "" {
        didSet {
            textView.text = text
            
            updateContentSize()
            if autoFollow {
                scrollToBottom()
            }
        }
    }
    
    private var shouldForwardTouches = false
    private var autoFollow = true
    
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
    
    // MARK: - Actions
    
    func settingsButtonTapped(sender: UIButton) {
        toggleToolbar()
    }
    
    func touchButtonTapped(sender: UIButton) {
        touchButton.selected = !touchButton.selected
        shouldForwardTouches = !shouldForwardTouches
    }
    
    func followButtonTapped(sender: UIButton) {
        followButton.selected = !followButton.selected
        autoFollow = !autoFollow
    }
    
    func clearButtonTapped(sender: UIButton) {
        text = ""
    }
    
    func closeGestureRecognized(sender: UITapGestureRecognizer) {
        toggleUI()
    }
    
    // MARK: - Helpers
    
    private func updateContentSize() {
        let size = (text as NSString).sizeWithAttributes([NSFontAttributeName: textView.font!])
        let width = size.width + bounds.width + 10
        let frame = CGRect(x: 0, y: 0, width: width, height: size.height)
        textView.frame = frame
        scrollView.contentSize = textView.bounds.size
    }
    
    private func scrollToBottom() {
        let diff = scrollView.contentSize.height - scrollView.bounds.size.height
        if diff > 0 {
            let bottomOffset = CGPoint(x: scrollView.contentOffset.x, y: diff)
            scrollView.setContentOffset(bottomOffset, animated: false)
        }
    }
    
    private func toggleToolbar() {
        let collapsed = toolbarLeadingConstraint.constant == -75
        toolbarLeadingConstraint.constant = collapsed ? -300 : -75
        UIView.animateWithDuration(0.3) {
            self.toolbar.layoutIfNeeded()
        }
    }
    
    private func toggleUI() {
        UIView.transitionWithView(self, duration: 0.3, options: .TransitionCrossDissolve, animations: { () -> Void in
            self.hidden = !self.hidden
            }, completion: nil)
    }
    
    // MARK: - UI
    
    private func configureUI() {
        configureOutlets()
        configureLayout()
    }
    
    private func configureOutlets() {
        configureScrollingTextView()
        configureToolbar()
        configureToolbarControls()
        configureCloseGesture()
    }
    
    private func configureScrollingTextView() {
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
        
        textView.editable = false
        textView.selectable = false
        textView.scrollEnabled = false
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 0, right: 0)
        textView.backgroundColor = UIColor.clearColor()
        textView.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.7)
    }
    
    private func configureToolbar() {
        toolbar.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
        toolbar.layer.cornerRadius = 12
        
        toolbarStack.axis = .Horizontal
        toolbarStack.alignment = .Fill
        toolbarStack.distribution = .FillEqually
    }
    
    private func configureToolbarControls() {
        settingsButton.setTitle("☀️", forState: .Normal)
        touchButton.setTitle("✨", forState: .Normal)
        touchButton.setTitle("⚡️", forState: .Selected)
        followButton.setTitle("🌟", forState: .Normal)
        followButton.setTitle("💫", forState: .Selected)
        clearButton.setTitle("🔥", forState: .Normal)
        
        touchButton.selected = true
        followButton.selected = true
        
        settingsButton.addTarget(self, action: Selector("settingsButtonTapped:"), forControlEvents: .TouchUpInside)
        touchButton.addTarget(self, action: Selector("touchButtonTapped:"), forControlEvents: .TouchUpInside)
        followButton.addTarget(self, action: Selector("followButtonTapped:"), forControlEvents: .TouchUpInside)
        clearButton.addTarget(self, action: Selector("clearButtonTapped:"), forControlEvents: .TouchUpInside)
    }
    
    private func configureCloseGesture() {
        closeGesture.numberOfTouchesRequired = 2
        closeGesture.numberOfTapsRequired = 2
        closeGesture.addTarget(self, action: Selector("closeGestureRecognized:"))
        addGestureRecognizer(closeGesture)
    }
    
    private func configureLayout() {
        scrollView.addSubview(textView)
        addSubview(scrollView)

        toolbarStack.addArrangedSubview(settingsButton)
        toolbarStack.addArrangedSubview(touchButton)
        toolbarStack.addArrangedSubview(followButton)
        toolbarStack.addArrangedSubview(clearButton)
        toolbar.addSubview(toolbarStack)
        addSubview(toolbar)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbarStack.translatesAutoresizingMaskIntoConstraints = false
        
        configureScrollViewConstraints()
        configureToolbarConstraints()
        configureToolbarStackConstraints()
    }
    
    private func configureScrollViewConstraints() {
        guard let scrollViewConstraints = scrollViewConstraints else { return }
        NSLayoutConstraint.activateConstraints(scrollViewConstraints)
    }
    
    private func configureToolbarConstraints() {
        toolbarLeadingConstraint = toolbar.leadingAnchor.constraintEqualToAnchor(trailingAnchor, constant: -300)
        guard let toolbarConstraints = toolbarConstraints else { return }
        NSLayoutConstraint.activateConstraints(toolbarConstraints)
    }
    
    private func configureToolbarStackConstraints() {
        guard let toolbarStackConstraints = toolbarStackConstraints else { return }
        NSLayoutConstraint.activateConstraints(toolbarStackConstraints)
    }
    
    private var scrollViewConstraints: [NSLayoutConstraint]? {
        guard let
            leading = scrollView.leadingAnchor.constraintEqualToAnchor(leadingAnchor),
            trailing = scrollView.trailingAnchor.constraintEqualToAnchor(trailingAnchor),
            top = scrollView.topAnchor.constraintEqualToAnchor(topAnchor),
            bottom = scrollView.bottomAnchor.constraintEqualToAnchor(bottomAnchor)
            else { return nil }
        return [leading, trailing, top, bottom]
    }
    
    private var toolbarConstraints: [NSLayoutConstraint]? {
        guard let
        width = toolbar.widthAnchor.constraintEqualToConstant(320),
        height = toolbar.heightAnchor.constraintEqualToConstant(50),
        centerY = toolbar.centerYAnchor.constraintEqualToAnchor(centerYAnchor)
            else { return nil }
        return [width, height, toolbarLeadingConstraint, centerY]
    }
    
    private var toolbarStackConstraints: [NSLayoutConstraint]? {
        guard let
            leading = toolbarStack.leadingAnchor.constraintEqualToAnchor(toolbar.leadingAnchor),
            trailing = toolbarStack.trailingAnchor.constraintEqualToAnchor(toolbar.trailingAnchor, constant: -20),
            top = toolbarStack.topAnchor.constraintEqualToAnchor(toolbar.topAnchor),
            bottom = toolbarStack.bottomAnchor.constraintEqualToAnchor(toolbar.bottomAnchor)
            else { return nil }
        return [leading, trailing, top, bottom]
    }
    
    // MARK: - Override
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateContentSize()
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, withEvent: event)
        
        if (hitView == scrollView || hitView == textView) && shouldForwardTouches {
            return nil
        }
        
        return hitView
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            toggleUI()
        }
    }
    
}
