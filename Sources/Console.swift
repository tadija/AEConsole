/**
 *  https://github.com/tadija/AEConsole
 *  Copyright (c) Marko Tadić 2016-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import UIKit
import AELog

/// Facade for displaying debug log in Console UI overlay on top of your app.
open class Console: LogDelegate {
    
    // MARK: - Properties

    /// Singleton
    public static let shared = Console()

    /// Console Settings
    public var settings: Settings {
        return brain.settings
    }

    internal let brain = Brain(with: Settings())
    private var window: UIWindow?
    
    // MARK: - API

    /// Enable Console UI by calling this method in your AppDelegate's `didFinishLaunchingWithOptions:`
    ///
    /// - Parameter window: Main window for the app (AppDelegate's window).
    open func configure(in window: UIWindow?) {
        Log.shared.delegate = self
        self.window = window
        self.brain.configureConsole(in: window)
    }
    
    /// Current state of Console UI visibility
    open var isHidden: Bool {
        return !brain.console.isOnScreen
    }
    
    /// Toggle Console UI
    open func toggle() {
        if let view = brain.console {
            if !view.isOnScreen {
                activateConsoleUI()
            }
            view.toggleUI()
        }
    }

    /// This will make {timestamp}.aelog file inside your App's Documents directory.
    open func exportLogFile() {
        brain.exportLogFile()
    }
    
    // MARK: - Init
    
    fileprivate init() {
        NotificationCenter.default.addObserver(self, selector: #selector(activateConsoleUI),
                                               name: .UIApplicationDidBecomeActive, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc
    fileprivate func activateConsoleUI() {
        if let window = window {
            window.bringSubview(toFront: brain.console)
            if settings.isShakeGestureEnabled {
                brain.console.becomeFirstResponder()
            }
        }
    }

    // MARK: - LogDelegate

    open func didLog(line: Line, mode: Log.Mode) {
        DispatchQueue.main.async { [weak self] in
            self?.brain.addLogLine(line)
        }
    }
    
}
