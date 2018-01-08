/**
 *  https://github.com/tadija/AEConsole
 *  Copyright (c) Marko Tadić 2016-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

/// Console settings
open class Settings {

    // MARK: Constants

    private struct Defaults {
        static let isEnabled = false
        static let isAutoStartEnabled = false
        static let isShakeGestureEnabled = true
        static let backColor = UIColor.black
        static let textColor = UIColor.white
        static let fontSize: CGFloat = 12.0
        static let rowHeight: CGFloat = 14.0
        static let opacity: CGFloat = 0.7
    }

    // MARK: Properties

    /// Console enabled flag (defaults to `true`)
    public var isEnabled = Defaults.isEnabled

    /// Auto start flag (defaults to `false`)
    public var isAutoStartEnabled = Defaults.isAutoStartEnabled

    /// Shake gesture flag (defaults to `true`)
    public var isShakeGestureEnabled = Defaults.isShakeGestureEnabled

    /// Background color
    public var backColor = Defaults.backColor

    /// Text color
    public var textColor = Defaults.textColor

    /// Font size
    public var fontSize = Defaults.fontSize

    /// Row height
    public var rowHeight = Defaults.rowHeight

    /// Console opacity
    public var opacity = Defaults.opacity

}
