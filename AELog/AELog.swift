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

public func aelog(message: Any = "", filePath: String = __FILE__, line: Int = __LINE__, function: String = __FUNCTION__) {
    AELog.sharedInstance.log(message: "\(message)", filePath: filePath, line: line, function: function)
}

// MARK: - AELogDelegate

public protocol AELogDelegate: class {
    func didLog(logLine: String)
}

extension AELogDelegate where Self: AppDelegate {
    
    func didLog(logLine: String) {
        let shared = AELog.sharedInstance
        if shared.settings.consoleEnabled {
            guard let window = self.window else { return }
            let console = shared.console
            console.addLogLine(logLine)
            console.becomeFirstResponder()
            window.bringSubviewToFront(console)
        }
    }
    
}

// MARK: - AELogSettings

public class AELogSettings {
    
    public struct Key {
        private static let Name = NSStringFromClass(AELog).componentsSeparatedByString(".").last!
        
        public static let Enabled = "Enabled"
        public static let Files = "Files"
        
        private static let ConsoleSettings = "Console"
        public struct Console {
            public static let Enabled = "Enabled"
            public static let AutoStart = "AutoStart"
            public static let BackColor = "BackColor"
            public static let TextColor = "TextColor"
            public static let Opacity = "Opacity"
        }
    }
    
    // MARK: - Properties
    
    private var settingsPath: String?
    
    // MARK: - Plist Helpers
    
    private lazy var logSettings: [String : AnyObject]? = { [unowned self] in
        if let path = self.settingsPath {
            return AELogSettings.settingsForPath(path)
        } else if let path = NSBundle.mainBundle().pathForResource(Key.Name, ofType: "plist") {
            return AELogSettings.settingsForPath(path)
        } else {
            guard let
                info = AELogSettings.infoPlist,
                settings = info[Key.Name] as? [String : AnyObject]
            else { return nil }
            return settings
        }
    }()
    
    private lazy var consoleSettings: [String : AnyObject]? = { [unowned self] in
        guard let
            settings = self.logSettings,
            console = settings[Key.ConsoleSettings] as? [String : AnyObject]
        else { return nil }
        return console
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
    
    // MARK: - Settings
    
    private lazy var enabled: Bool = { [unowned self] in
        guard let
            settings = self.logSettings,
            enabled = settings[Key.Enabled] as? Bool
        else { return true }
        return enabled
    }()
    
    private lazy var files: [String : Bool]? = { [unowned self] in
        guard let
            settings = self.logSettings,
            files = settings[Key.Files] as? [String : Bool]
        else { return nil }
        return files
    }()
    
    private lazy var consoleEnabled: Bool = { [unowned self] in
        guard let
            settings = self.consoleSettings,
            enabled = settings[Key.Console.Enabled] as? Bool
        else { return true }
        return enabled
    }()
    
    private lazy var consoleAutoStart: Bool = { [unowned self] in
        guard let
            settings = self.consoleSettings,
            autoStart = settings[Key.Console.AutoStart] as? Bool
        else { return true }
        return autoStart
    }()
    
    private lazy var consoleBackColor: UIColor? = { [unowned self] in
        return self.consoleColorForKey(Key.Console.BackColor)
    }()
    
    private lazy var consoleTextColor: UIColor? = { [unowned self] in
        return self.consoleColorForKey(Key.Console.TextColor)
    }()
    
    private lazy var consoleOpacity: CGFloat? = { [unowned self] in
        guard let
            settings = self.consoleSettings,
            opacity = settings[Key.Console.Opacity] as? CGFloat
        else { return nil }
        return opacity
    }()
    
    // MARK: - Color Helpers
    
    private func consoleColorForKey(key: String) -> UIColor? {
        guard let
            settings = consoleSettings,
            hex = settings[key] as? String
            else { return nil }
        let color = AELogSettings.colorFromHexString(hex)
        return color
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
    
}

// MARK: - AELog

public class AELog {
    
    // MARK: - API
    
    public class func launch(withDelegate delegate: AELogDelegate? = nil, settingsPath: String? = nil) {
        AELog.sharedInstance.delegate = delegate
        AELog.sharedInstance.settings.settingsPath = settingsPath
    }
    
    // MARK: - Properties
    
    private static let sharedInstance = AELog()
    private let settings = AELogSettings()
    
    private let console = AEConsoleView()
    private weak var delegate: AELogDelegate? {
        didSet {
            addConsoleToAppWindow()
        }
    }
    
    // MARK: - Helpers
    
    private func addConsoleToAppWindow() {
        guard let
            app = delegate as? AppDelegate,
            window = app.window
        else { return }
        
        console.frame = window.bounds
        console.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        console.hidden = !settings.consoleAutoStart
        
        console.backColor = settings.consoleBackColor ?? AEConsoleView.Default.BackColor
        console.textColor = settings.consoleTextColor ?? AEConsoleView.Default.TextColor
        console.opacity = settings.consoleOpacity ?? AEConsoleView.Default.Opacity
        
        window.addSubview(console)
    }
    
    // MARK: - Actions
    
    private func log(message message: String, filePath: String, line: Int, function: String) {
        if settings.enabled {
            let fileName = fileNameForPath(filePath)
            if fileEnabled(fileName) {
                let logLine = generateLogLine(message: message, fileName: fileName, line: line, function: function)
                NSLog(logLine)
                delegate?.didLog(logLine)
            }
        }
    }
    
    private func fileEnabled(fileName: String) -> Bool {
        guard let
            files = settings.files,
            fileEnabled = files[fileName]
        else { return true }
        return fileEnabled
    }
    
    private func generateLogLine(message message: String, fileName: String, line: Int, function: String) -> String {
        let text = message == "" ? "" : " | \"\(message)\""
        let logLine = "-- [\(threadName)] \(fileName) (\(line)) -> \(function)\(text)"
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

// MARK: - AEConsoleView

private class AEConsoleCell: UITableViewCell {
    
    static let identifier = "AEConsoleCell"
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = UIColor.clearColor()
        guard let label = textLabel else { return }
        label.font = UIFont.systemFontOfSize(AEConsoleView.Default.FontSize)
        label.textColor = AEConsoleView.textColor
        label.numberOfLines = 1
        label.textAlignment = .Left
    }
    
    private override func prepareForReuse() {
        super.prepareForReuse()
        textLabel?.textColor = AEConsoleView.textColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = bounds
    }
    
}

class AEConsoleView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    private struct Default {
        static let FontSize: CGFloat = 12.0
        static let RowHeight: CGFloat = 14.0

        static let ToolbarWidth: CGFloat = 300
        static let ToolbarHeight: CGFloat = 50
        static let ToolbarCollapsed: CGFloat = -75
        static let ToolbarExpanded: CGFloat = -300
        static let MagicNumber: CGFloat = 10
        
        static let BackColor = UIColor.blackColor()
        static let TextColor = UIColor.whiteColor()
        static let Opacity: CGFloat = 0.7
    }
    
    // MARK: - Outlets
    
    private let tableView = UITableView()
    
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
    
    private var maxLineWidth: CGFloat = 0.0
    private var currentOffsetX = -Default.MagicNumber
    
    private var lines = [String]() {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        tableView.reloadData()
        updateContentSize()
        if autoFollow {
            scrollToBottom()
        }
    }
    
    private var backColor = Default.BackColor
    private var textColor = Default.TextColor
    private var opacity: CGFloat = Default.Opacity {
        didSet {
            configureColorsWithOpacity(opacity)
        }
    }
    
    private static var textColor: UIColor = Default.TextColor.colorWithAlphaComponent(Default.Opacity)
    
    private func configureColorsWithOpacity(opacity: CGFloat) {
        tableView.backgroundColor = backColor.colorWithAlphaComponent(opacity)
        
        let textOpacity = max(0.3, opacity)
        AEConsoleView.textColor = textColor.colorWithAlphaComponent(textOpacity)
        
        let toolbarOpacity = min(0.7, opacity * 1.5)
        toolbar.backgroundColor = backColor.colorWithAlphaComponent(toolbarOpacity)
        
        let toolbarBorderOpacity = toolbarOpacity / 2
        toolbar.layer.borderColor = backColor.colorWithAlphaComponent(toolbarBorderOpacity).CGColor
        toolbar.layer.borderWidth = 1.0
        
        if !lines.isEmpty {
            // refresh text color
            tableView.reloadData()
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
        opacity = Default.Opacity
    }
    
    // MARK: - Actions
    
    func addLogLine(logLine: String) {
        let calculatedLineWidth = widthForLine(logLine)
        if calculatedLineWidth > maxLineWidth {
            maxLineWidth = calculatedLineWidth
        }
        lines.append(logLine)
    }
    
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
        lines.removeAll()
    }
    
    func opacityGestureRecognized(sender: UIPanGestureRecognizer) {
        if sender.state == .Ended {
            let xTranslation = sender.translationInView(toolbar).x
            if abs(xTranslation) > (3 * Default.MagicNumber) {
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
    
    private func widthForLine(line: String) -> CGFloat {
        let maxSize = CGSize(width: CGFloat.max, height: Default.RowHeight)
        let options = NSStringDrawingOptions.UsesLineFragmentOrigin
        let attributes = [NSFontAttributeName : UIFont.systemFontOfSize(Default.FontSize)]
        let size = (line as NSString).boundingRectWithSize(maxSize, options: options, attributes: attributes, context: nil)
        let width = size.width
        return width
    }
    
    private func opacityForLocation(location: CGPoint) -> CGFloat {
        let calculatedOpacity = ((location.x * 1.0) / 300)
        let minOpacity = max(0.1, calculatedOpacity)
        let maxOpacity = min(0.9, minOpacity)
        return maxOpacity
    }
    
    private func updateContentSize() {
        let maxWidth = max(maxLineWidth, bounds.width)
        
        let newFrame = CGRect(x: 0.0, y: 0.0, width: maxWidth, height: bounds.height)
        tableView.frame = newFrame
        
        let defaultInset = Default.MagicNumber
        let newInset = UIEdgeInsets(top: defaultInset, left: defaultInset, bottom: defaultInset, right: maxWidth)
        tableView.contentInset = newInset
    }
    
    private func scrollToBottom() {
        let diff = tableView.contentSize.height - tableView.bounds.size.height
        if diff > 0 {
            let offsetY = diff + Default.MagicNumber
            let bottomOffset = CGPoint(x: currentOffsetX, y: offsetY)
            tableView.setContentOffset(bottomOffset, animated: false)
        }
    }
    
    private func toggleToolbar() {
        let collapsed = toolbarLeading.constant == Default.ToolbarCollapsed
        toolbarLeading.constant = collapsed ? Default.ToolbarExpanded : Default.ToolbarCollapsed
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
    }
    
    private func configureOutlets() {
        configureTableView()
        configureToolbar()
        configureToolbarButtons()
        configureOpacityGesture()
        configureCloseGesture()
    }
    
    private func configureTableView() {
        tableView.rowHeight = Default.RowHeight
        tableView.allowsSelection = false
        tableView.separatorStyle = .None

        tableView.registerClass(AEConsoleCell.self, forCellReuseIdentifier: AEConsoleCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func configureToolbar() {
        toolbar.alpha = 0.3
        toolbar.layer.cornerRadius = Default.MagicNumber
        
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
        addSubview(tableView)

        toolbarStack.addArrangedSubview(settingsButton)
        toolbarStack.addArrangedSubview(touchButton)
        toolbarStack.addArrangedSubview(followButton)
        toolbarStack.addArrangedSubview(clearButton)
        toolbar.addSubview(toolbarStack)
        addSubview(toolbar)

        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbarStack.translatesAutoresizingMaskIntoConstraints = false

        configureToolbarConstraints()
        configureToolbarStackConstraints()
    }
    
    private func configureToolbarConstraints() {
        toolbarLeading = toolbar.leadingAnchor.constraintEqualToAnchor(trailingAnchor, constant: Default.ToolbarCollapsed)
        guard let toolbarConstraints = toolbarConstraints else { return }
        NSLayoutConstraint.activateConstraints(toolbarConstraints)
    }
    
    private func configureToolbarStackConstraints() {
        guard let toolbarStackConstraints = toolbarStackConstraints else { return }
        NSLayoutConstraint.activateConstraints(toolbarStackConstraints)
    }
    
    private var toolbarConstraints: [NSLayoutConstraint]? {
        guard let
        width = toolbar.widthAnchor.constraintEqualToConstant(Default.ToolbarWidth + Default.MagicNumber),
        height = toolbar.heightAnchor.constraintEqualToConstant(Default.ToolbarHeight),
        centerY = toolbar.centerYAnchor.constraintEqualToAnchor(centerYAnchor)
            else { return nil }
        return [width, height, toolbarLeading, centerY]
    }
    
    private var toolbarStackConstraints: [NSLayoutConstraint]? {
        guard let
            leading = toolbarStack.leadingAnchor.constraintEqualToAnchor(toolbar.leadingAnchor),
            trailing = toolbarStack.trailingAnchor.constraintEqualToAnchor(toolbar.trailingAnchor, constant: -Default.MagicNumber),
            top = toolbarStack.topAnchor.constraintEqualToAnchor(toolbar.topAnchor),
            bottom = toolbarStack.bottomAnchor.constraintEqualToAnchor(toolbar.bottomAnchor)
            else { return nil }
        return [leading, trailing, top, bottom]
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lines.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(AEConsoleCell.identifier) as! AEConsoleCell
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let logLine = lines[indexPath.row]
        cell.textLabel?.text = logLine
    }
    
    // MARK: - Override
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateContentSize()
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, withEvent: event)
        
        if hitView?.superview != toolbarStack && forwardTouches {
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
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            currentOffsetX = scrollView.contentOffset.x
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        currentOffsetX = scrollView.contentOffset.x
    }
    
}
