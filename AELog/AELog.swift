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

public func aelog(message: Any = "",
    thread: NSThread = NSThread.currentThread(),
    path: String = __FILE__,
    line: Int = __LINE__,
    function: String = __FUNCTION__)
{
    AELog.sharedInstance.log(thread: thread, path: path, line: line, function: function, message: "\(message)")
}

// MARK: - AELogLine

public struct AELogLine: CustomStringConvertible {
    
    public let timestamp: NSDate
    public let thread: NSThread
    public let file: String
    public let line: Int
    public let function: String
    public let message: String
    
    public var description: String {
        let date = AELogSettings.sharedInstance.dateFormatter.stringFromDate(timestamp)
        let threadName = thread.isMainThread ? "Main" : (thread.name ?? "Unknown")
        let message = self.message == "" ? "" : " | \"\(self.message)\""
        let desc = "\(date) -- [\(threadName)] \(self.file) (\(self.line)) -> \(self.function)\(message)"
        return desc
    }
    
    public init(thread: NSThread, file: String, line: Int, function: String, message: String) {
        self.timestamp = NSDate()
        self.thread = thread
        self.file = file
        self.line = line
        self.function = function
        self.message = message
    }
    
}

// MARK: - AELogDelegate

public protocol AELogDelegate: class {
    func didLog(logLine: AELogLine)
}

extension AELogDelegate where Self: AppDelegate {
    
    func didLog(logLine: AELogLine) {
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

private class AELogSettings {
    
    private struct Default {
        private static let Enabled = true

        private struct Console {
            private static let Enabled = true
            private static let AutoStart = true
            private static let BackColor = UIColor.blackColor()
            private static let TextColor = UIColor.whiteColor()
            private static let FontSize: CGFloat = 12.0
            private static let RowHeight: CGFloat = 14.0
            private static let Opacity: CGFloat = 0.7
        }
    }
    
    private typealias Key = AELog.Setting
    
    // MARK: - Singleton
    
    private static let sharedInstance = AELogSettings()
    
    // MARK: - Properties
    
    private let dateFormatter = NSDateFormatter()
    private var textOpacity = Default.Console.Opacity
    
    // MARK: - Init
    
    private init() {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    }
    
    // MARK: - Plist Helpers
    
    private lazy var logSettings: [String : AnyObject]? = {
        guard let
            path = NSBundle.mainBundle().pathForResource("AELog", ofType: "plist"),
            settings = NSDictionary(contentsOfFile: path) as? [String : AnyObject]
        else { return nil }
        return settings
    }()
    
    private lazy var consoleSettings: [String : AnyObject]? = { [unowned self] in
        guard let
            settings = self.logSettings,
            console = settings[Key.ConsoleSettings] as? [String : AnyObject]
        else { return nil }
        return console
    }()
    
    // MARK: - Settings
    
    private lazy var enabled: Bool = { [unowned self] in
        guard let
            settings = self.logSettings,
            enabled = settings[Key.Enabled] as? Bool
        else { return Default.Enabled }
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
        guard let enabled = self.boolForKey(Key.Console.Enabled)
        else { return Default.Console.Enabled }
        return enabled
    }()
    
    private lazy var consoleAutoStart: Bool = { [unowned self] in
        guard let autoStart = self.boolForKey(Key.Console.AutoStart)
        else { return Default.Console.AutoStart }
        return autoStart
    }()
    
    private lazy var consoleBackColor: UIColor = { [unowned self] in
        guard let color = self.colorForKey(Key.Console.BackColor)
        else { return Default.Console.BackColor }
        return color
    }()
    
    private lazy var consoleTextColor: UIColor = { [unowned self] in
        guard let color = self.colorForKey(Key.Console.TextColor)
        else { return Default.Console.TextColor }
        return color
    }()
    
    private lazy var consoleFontSize: CGFloat = { [unowned self] in
        guard let fontSize = self.numberForKey(Key.Console.FontSize)
        else { return Default.Console.FontSize }
        return fontSize
    }()
    
    private lazy var consoleRowHeight: CGFloat = { [unowned self] in
        guard let rowHeight = self.numberForKey(Key.Console.RowHeight)
        else { return Default.Console.RowHeight }
        return rowHeight
    }()
    
    private lazy var consoleOpacity: CGFloat = { [unowned self] in
        guard let opacity = self.numberForKey(Key.Console.Opacity)
        else { return Default.Console.Opacity }
        return opacity
    }()
    
    // MARK: - Helpers
    
    private func boolForKey(key: String) -> Bool? {
        guard let
            settings = consoleSettings,
            bool = settings[key] as? Bool
        else { return nil }
        return bool
    }
    
    private func numberForKey(key: String) -> CGFloat? {
        guard let
            settings = consoleSettings,
            number = settings[key] as? CGFloat
        else { return nil }
        return number
    }
    
    private func colorForKey(key: String) -> UIColor? {
        guard let
            settings = consoleSettings,
            hex = settings[key] as? String
            else { return nil }
        let color = colorFromHexString(hex)
        return color
    }
    
    private func colorFromHexString(hex: String) -> UIColor? {
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
    
    public struct Setting {
        public static let Enabled = "Enabled"
        public static let Files = "Files"
        
        private static let ConsoleSettings = "Console"
        public struct Console {
            public static let Enabled = "Enabled"
            public static let AutoStart = "AutoStart"
            public static let BackColor = "BackColor"
            public static let TextColor = "TextColor"
            public static let FontSize = "FontSize"
            public static let RowHeight = "RowHeight"
            public static let Opacity = "Opacity"
        }
    }
    
    // MARK: - Singleton
    
    private static let sharedInstance = AELog()
    
    // MARK: - API
    
    public class func launch(withDelegate delegate: AELogDelegate? = nil) {
        AELog.sharedInstance.delegate = delegate
    }
    
    // MARK: - Properties
    
    private let settings = AELogSettings.sharedInstance
    
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
        
        window.addSubview(console)
    }
    
    // MARK: - API
    
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
    
    // MARK: - Helpers
    
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

// MARK: - AEConsoleView

private class AEConsoleCell: UITableViewCell {
    
    static let identifier = "AEConsoleCell"
    
    // MARK: - Properties
    
    private let settings = AELogSettings.sharedInstance
    
    // MARK: - Init
    
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
        label.font = UIFont.systemFontOfSize(settings.consoleFontSize)
        label.textColor = settings.consoleTextColor.colorWithAlphaComponent(settings.textOpacity)
        label.numberOfLines = 1
        label.textAlignment = .Left
    }
    
    // MARK: - Override
    
    private override func prepareForReuse() {
        super.prepareForReuse()
        textLabel?.textColor = settings.consoleTextColor.colorWithAlphaComponent(settings.textOpacity)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = bounds
    }
    
}

class AEConsoleView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    private struct Layout {
        static let ToolbarWidth: CGFloat = 300
        static let ToolbarHeight: CGFloat = 50
        static let ToolbarCollapsed: CGFloat = -75
        static let ToolbarExpanded: CGFloat = -300
        static let MagicNumber: CGFloat = 10
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
    
    private let settings = AELogSettings.sharedInstance
    
    private var forwardTouches = false
    private var autoFollow = true
    
    private var maxLineWidth: CGFloat = 0.0
    private var currentOffsetX = -Layout.MagicNumber
    
    private var lines = [AELogLine]() {
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

    private var opacity: CGFloat = 1.0 {
        didSet {
            configureColorsWithOpacity(opacity)
        }
    }
    
    private func configureColorsWithOpacity(opacity: CGFloat) {
        tableView.backgroundColor = settings.consoleBackColor.colorWithAlphaComponent(opacity)
        
        let textOpacity = max(0.3, opacity)
        settings.textOpacity = textOpacity
        
        let toolbarOpacity = min(0.7, opacity * 1.5)
        toolbar.backgroundColor = settings.consoleBackColor.colorWithAlphaComponent(toolbarOpacity)
        
        let toolbarBorderOpacity = toolbarOpacity / 2
        toolbar.layer.borderColor = settings.consoleBackColor.colorWithAlphaComponent(toolbarBorderOpacity).CGColor
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
        opacity = settings.consoleOpacity
    }
    
    // MARK: - Actions
    
    func addLogLine(logLine: AELogLine) {
        let calculatedLineWidth = widthForLine(logLine.description)
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
            if abs(xTranslation) > (3 * Layout.MagicNumber) {
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
        let maxSize = CGSize(width: CGFloat.max, height: settings.consoleRowHeight)
        let options = NSStringDrawingOptions.UsesLineFragmentOrigin
        let attributes = [NSFontAttributeName : UIFont.systemFontOfSize(settings.consoleFontSize)]
        let nsLine = line as NSString
        let size = nsLine.boundingRectWithSize(maxSize, options: options, attributes: attributes, context: nil)
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
        
        let defaultInset = Layout.MagicNumber
        let newInset = UIEdgeInsets(top: defaultInset, left: defaultInset, bottom: defaultInset, right: maxWidth)
        tableView.contentInset = newInset
    }
    
    private func scrollToBottom() {
        let diff = tableView.contentSize.height - tableView.bounds.size.height
        if diff > 0 {
            let offsetY = diff + Layout.MagicNumber
            let bottomOffset = CGPoint(x: currentOffsetX, y: offsetY)
            tableView.setContentOffset(bottomOffset, animated: false)
        }
    }
    
    private func toggleToolbar() {
        let collapsed = toolbarLeading.constant == Layout.ToolbarCollapsed
        toolbarLeading.constant = collapsed ? Layout.ToolbarExpanded : Layout.ToolbarCollapsed
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
        tableView.rowHeight = settings.consoleRowHeight
        tableView.allowsSelection = false
        tableView.separatorStyle = .None

        tableView.registerClass(AEConsoleCell.self, forCellReuseIdentifier: AEConsoleCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func configureToolbar() {
        toolbar.alpha = 0.3
        toolbar.layer.cornerRadius = Layout.MagicNumber
        
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
        toolbarLeading = toolbar.leadingAnchor.constraintEqualToAnchor(trailingAnchor, constant: Layout.ToolbarCollapsed)
        guard let toolbarConstraints = toolbarConstraints else { return }
        NSLayoutConstraint.activateConstraints(toolbarConstraints)
    }
    
    private func configureToolbarStackConstraints() {
        guard let toolbarStackConstraints = toolbarStackConstraints else { return }
        NSLayoutConstraint.activateConstraints(toolbarStackConstraints)
    }
    
    private var toolbarConstraints: [NSLayoutConstraint]? {
        guard let
        width = toolbar.widthAnchor.constraintEqualToConstant(Layout.ToolbarWidth + Layout.MagicNumber),
        height = toolbar.heightAnchor.constraintEqualToConstant(Layout.ToolbarHeight),
        centerY = toolbar.centerYAnchor.constraintEqualToAnchor(centerYAnchor)
            else { return nil }
        return [width, height, toolbarLeading, centerY]
    }
    
    private var toolbarStackConstraints: [NSLayoutConstraint]? {
        guard let
            leading = toolbarStack.leadingAnchor.constraintEqualToAnchor(toolbar.leadingAnchor),
            trailing = toolbarStack.trailingAnchor.constraintEqualToAnchor(toolbar.trailingAnchor, constant: -Layout.MagicNumber),
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
        cell.textLabel?.text = logLine.description
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
