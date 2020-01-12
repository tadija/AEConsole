/**
 *  https://github.com/tadija/AEConsole
 *  Copyright © 2016-2020 Marko Tadić
 *  Licensed under the MIT license
 */

import UIKit

/// Console settings
open class Settings {

    // MARK: Constants

    private struct Defaults {
        static let isShakeGestureEnabled = true
        static let backColor = UIColor.black
        static let textColor = UIColor.white
        static let fontSize: CGFloat = 12.0
        static let rowSpacing: CGFloat = 4.0
        static let opacity: CGFloat = 0.7
    }

    // MARK: Properties

    /// Shake gesture flag (defaults to `true`)
    public var isShakeGestureEnabled = Defaults.isShakeGestureEnabled

    /// Background color
    public var backColor = Defaults.backColor

    /// Text color
    public var textColor = Defaults.textColor

    /// Font size
    public var fontSize = Defaults.fontSize

    /// Row height
    public var rowSpacing = Defaults.rowSpacing

    /// Console opacity
    public var opacity = Defaults.opacity

    // MARK: Helpers

    internal lazy var consoleFont: UIFont = {
        return .monospacedDigitSystemFont(ofSize: fontSize, weight: .regular)
    }()

    internal lazy var textColorWithOpacity: UIColor = {
        textColor.withAlphaComponent(Defaults.opacity)
    }()

    internal var estimatedRowHeight: CGFloat {
        return fontSize + rowSpacing
    }

}
