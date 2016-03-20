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
    func didLog(logLine: String)
}

extension AELogDelegate where Self: AppDelegate {
    
    func didLog(logLine: String) {
        guard let window = self.window else { return }
        let logView = AELog.sharedInstance.logView
        logView.text += "\(logLine)\n"
        window.bringSubviewToFront(logView)
        logView.becomeFirstResponder()
    }
    
}

// MARK: - AELog

public class AELog {
    
    private struct Key {
        static let Name = NSStringFromClass(AELog).componentsSeparatedByString(".").last!
        static let Enabled = "Enabled"
        static let BackColor = "BackColor"
        static let TextColor = "TextColor"
        static let Opacity = "Opacity"
    }
    
    // MARK: - API
    
    public class func launch(withDelegate delegate: AELogDelegate? = nil, settingsPath: String? = nil) {
        AELog.sharedInstance.delegate = delegate
        AELog.sharedInstance.settingsPath = settingsPath
    }
    
    // MARK: - Properties
    
    private static let sharedInstance = AELog()
    
    private let logView = LogView()
    
    private weak var delegate: AELogDelegate? {
        didSet {
            addLogViewToAppWindow()
        }
    }
    
    private var settingsPath: String?
    
    // MARK: - Helpers
    
    private func addLogViewToAppWindow() {
        guard let
            app = delegate as? AppDelegate,
            window = app.window
        else { return }
        
        logView.frame = window.bounds
        logView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        configureLogViewTheme()
        
        window.addSubview(logView)
    }
    
    private func configureLogViewTheme() {
        if let backColor = settingBackColor {
            logView.backColor = backColor
        }
        if let textColor = settingTextColor {
            logView.textColor = textColor
        }
        if let opacity = settingOpacity {
            logView.opacity = opacity
        }
    }
    
    private lazy var settingEnabled: Bool = { [unowned self] in
        guard let
            settings = self.logSettings,
            enabled = settings[Key.Enabled] as? Bool
        else { return false }
        return enabled
    }()
    
    private var settingBackColor: UIColor? {
        return colorForKey(Key.BackColor)
    }
    
    private var settingTextColor: UIColor? {
        return colorForKey(Key.TextColor)
    }
    
    private func colorForKey(key: String) -> UIColor? {
        guard let
            settings = logSettings,
            hex = settings[key] as? String
            else { return nil }
        let color = AELog.colorFromHexString(hex)
        return color
    }
    
    private var settingOpacity: CGFloat? {
        guard let
            settings = logSettings,
            opacity = settings[Key.Opacity] as? CGFloat
        else { return nil }
        return opacity
    }
    
    private class func colorFromHexString(hex: String) -> UIColor? {
        let scanner = NSScanner(string: hex)
        var hexValue: UInt32 = 0
        if scanner.scanHexInt(&hexValue) {
            let red   = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((hexValue & 0x00FF00) >> 8) / 255.0
            let blue  = CGFloat((hexValue & 0x0000FF)) / 255.0
            let color = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
            return color
        } else { return nil }
    }
    
    private lazy var logSettings: [String : AnyObject]? = { [unowned self] in
        if let path = self.settingsPath {
            return AELog.settingsForPath(path)
        } else if let path = NSBundle.mainBundle().pathForResource(Key.Name, ofType: "plist") {
            return AELog.settingsForPath(path)
        } else {
            guard let
                info = AELog.infoPlist,
                settings = info[Key.Name] as? [String : AnyObject]
            else { return nil }
            return settings
        }
    }()
    
    private static func settingsForPath(path: String?) -> [String : AnyObject]? {
        guard let
            path = path,
            settings = NSDictionary(contentsOfFile: path) as? [String : AnyObject]
        else { return nil }
        return settings
    }
    
    private static var infoPlist: NSDictionary? {
        guard let
            path = NSBundle.mainBundle().pathForResource("Info", ofType: "plist"),
            info = NSDictionary(contentsOfFile: path)
            else { return nil }
        return info
    }
    
    // MARK: - Actions
    
    private func log(text text: String, path: String, line: Int, function: String) {
        if settingEnabled {
            let logLine = generateLogLine(text: text, path: path, line: line, function: function)
            NSLog(logLine)
            delegate?.didLog(logLine)
        }
    }
    
    private func generateLogLine(text text: String, path: String, line: Int, function: String) -> String {
        let fileName = fileNameForPath(path)
        let message = text == "" ? "" : " | \"\(text)\""
        let logLine = "-- [\(threadName)] \(fileName) (\(line)) -> \(function)\(message)"
        return logLine
    }
    
    private func fileNameForPath(path: String) -> String {
        guard let
            fileName = NSURL(fileURLWithPath: path).URLByDeletingPathExtension?.lastPathComponent
        else { return "Unknown" }
        return fileName
    }
    
    private var threadName: String {
        let thread = NSThread.currentThread()
        let name = thread.isMainThread ? "Main" : (thread.name ?? "Unknown")
        return name
    }
    
}

// MARK: - LogView

class LogView: UIView {
    
    private struct Constant {
        static let Opacity: CGFloat = 0.7
        static let ToolbarWidth: CGFloat = 300
        static let ToolbarHeight: CGFloat = 50
        static let ToolbarCollapsed: CGFloat = -75
        static let ToolbarExpanded: CGFloat = -300
        static let MagicNumber: CGFloat = 10
    }
    
    // MARK: - Outlets
    
    private let scrollView = UIScrollView()
    private let textView = UITextView()
    
    private let toolbar = UIView()
    private let toolbarStack = UIStackView()
    private var toolbarLeading: NSLayoutConstraint!
    
    private let settingsButton = UIButton()
    private let touchButton = UIButton()
    private let followButton = UIButton()
    private let clearButton = UIButton()
    
    private let opacityGesture = UIPanGestureRecognizer()
    private let closeGesture = UITapGestureRecognizer()
    
    // MARK: - Properties
    
    private var forwardTouches = false
    private var autoFollow = true
    
    var text = "" {
        didSet {
            textView.text = text
            
            updateContentSize()
            if autoFollow {
                scrollToBottom()
            }
        }
    }
    
    private var backColor = UIColor.blackColor()
    private var textColor = UIColor.whiteColor()
    private var opacity: CGFloat = Constant.Opacity {
        didSet {
            configureUIWithOpacity(opacity)
        }
    }
    
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
        forwardTouches = !forwardTouches
    }
    
    func followButtonTapped(sender: UIButton) {
        followButton.selected = !followButton.selected
        autoFollow = !autoFollow
    }
    
    func clearButtonTapped(sender: UIButton) {
        text = ""
    }
    
    func opacityGestureRecognized(sender: UIPanGestureRecognizer) {
        if sender.state == .Ended {
            let xTranslation = sender.translationInView(toolbar).x
            if abs(xTranslation) > (3 * Constant.MagicNumber) {
                let location = sender.locationInView(toolbar)
                let opacity = opacityForLocation(location)
                self.opacity = opacity
            }
        }
    }
    
    func closeGestureRecognized(sender: UITapGestureRecognizer) {
        toggleUI()
    }
    
    // MARK: - Helpers
    
    private func opacityForLocation(location: CGPoint) -> CGFloat {
        let calculatedOpacity = ((location.x * 1.0) / 300)
        let minOpacity = max(0.1, calculatedOpacity)
        let maxOpacity = min(0.9, minOpacity)
        return maxOpacity
    }
    
    private func updateContentSize() {
        let size = (text as NSString).sizeWithAttributes([NSFontAttributeName: textView.font!])
        let width = size.width + bounds.width + Constant.MagicNumber
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
        let collapsed = toolbarLeading.constant == Constant.ToolbarCollapsed
        toolbarLeading.constant = collapsed ? Constant.ToolbarExpanded : Constant.ToolbarCollapsed
        UIView.animateWithDuration(0.3) {
            self.toolbar.alpha = collapsed ? 1.0 : 0.3
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
        configureUIWithOpacity(0.7)
    }
    
    private func configureUIWithOpacity(opacity: CGFloat) {
        scrollView.backgroundColor = backColor.colorWithAlphaComponent(opacity)
        let textOpacity = max(0.3, opacity)
        textView.textColor = textColor.colorWithAlphaComponent(textOpacity)
        let toolbarOpacity = min(0.7, opacity * 1.5)
        toolbar.backgroundColor = backColor.colorWithAlphaComponent(toolbarOpacity)
    }
    
    private func configureOutlets() {
        configureScrollingTextView()
        configureToolbar()
        configureToolbarButtons()
        configureOpacityGesture()
        configureCloseGesture()
    }
    
    private func configureScrollingTextView() {
        scrollView.alwaysBounceVertical = true
        
        textView.backgroundColor = UIColor.clearColor()
        textView.editable = false
        textView.selectable = false
        textView.scrollEnabled = false
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsets(top: Constant.MagicNumber, left: 4, bottom: 0, right: 0)
    }
    
    private func configureToolbar() {
        toolbar.layer.cornerRadius = Constant.MagicNumber
        toolbar.alpha = 0.3
        
        toolbarStack.axis = .Horizontal
        toolbarStack.alignment = .Fill
        toolbarStack.distribution = .FillEqually
    }
    
    private func configureToolbarButtons() {
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
    
    private func configureOpacityGesture() {
        opacityGesture.addTarget(self, action: "opacityGestureRecognized:")
        toolbar.addGestureRecognizer(opacityGesture)
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
        toolbarLeading = toolbar.leadingAnchor.constraintEqualToAnchor(trailingAnchor, constant: Constant.ToolbarCollapsed)
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
        width = toolbar.widthAnchor.constraintEqualToConstant(Constant.ToolbarWidth + Constant.MagicNumber),
        height = toolbar.heightAnchor.constraintEqualToConstant(Constant.ToolbarHeight),
        centerY = toolbar.centerYAnchor.constraintEqualToAnchor(centerYAnchor)
            else { return nil }
        return [width, height, toolbarLeading, centerY]
    }
    
    private var toolbarStackConstraints: [NSLayoutConstraint]? {
        guard let
            leading = toolbarStack.leadingAnchor.constraintEqualToAnchor(toolbar.leadingAnchor),
            trailing = toolbarStack.trailingAnchor.constraintEqualToAnchor(toolbar.trailingAnchor, constant: -Constant.MagicNumber),
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
        
        if (hitView == scrollView || hitView == textView) && forwardTouches {
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
