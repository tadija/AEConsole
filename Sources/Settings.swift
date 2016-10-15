//
// Settings.swift
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

/**
 Helper for accessing settings from the external file (same file used by `AELog`).
 
 Create `AELog.plist` dictionary file and add it to your target.
 Add `Console` dictionary inside it and there you can manage all console settings.
 
 There is `Key` struct which contains possible keys for all settings.
 */
open class AEConsoleSettings: Settings {
    
    // MARK: Constants
    
    /// Setting keys which can be used in `Console` dictionary inside `AELog.plist`.
    public struct Key {
        public static let ConsoleSettings = "Console"
        
        public struct Console {
            /// Boolean - Console UI enabled flag (defaults to `YES`)
            public static let Enabled = "Enabled"
            
            /// Boolean - Console UI visible on app start flag (defaults to `NO`)
            public static let AutoStart = "AutoStart"
            
            /// Boolean - Shake gesture enabled flag (defaults to `YES`)
            public static let ShakeGesture = "ShakeGesture"
            
            /// String - Hex string for Console background color (defaults to 000000)
            public static let BackColor = "BackColor"
            
            /// String - Hex string for Console text color (defaults to FFFFFF)
            public static let TextColor = "TextColor"
            
            /// Number - Console UI font size (defaults to 12)
            public static let FontSize = "FontSize"
            
            /// Number - Console UI row height (defaults to 14)
            public static let RowHeight = "RowHeight"
            
            /// Number - Console UI opacity (defaults to 0.7)
            public static let Opacity = "Opacity"
        }
    }
    
    fileprivate struct Default {
        fileprivate static let Enabled = true
        fileprivate static let AutoStart = false
        fileprivate static let ShakeGesture = true
        fileprivate static let BackColor = UIColor.black
        fileprivate static let TextColor = UIColor.white
        fileprivate static let FontSize: CGFloat = 12.0
        fileprivate static let RowHeight: CGFloat = 14.0
        fileprivate static let Opacity: CGFloat = 0.7
    }
    
    // MARK: Properties
    
    static let sharedInstance = AEConsoleSettings()
    
    lazy var textColorWithOpacity: UIColor = { [unowned self] in
        self.consoleTextColor.withAlphaComponent(Default.Opacity)
        }()
    
    fileprivate lazy var consoleSettings: [String : AnyObject]? = { [unowned self] in
        guard let
            settings = self.plist,
            let console = settings[Key.ConsoleSettings] as? [String : AnyObject]
            else { return nil }
        return console
        }()
    
    // MARK: Settings
    
    lazy var consoleFont: UIFont = {
        return UIFont.monospacedDigitSystemFont(ofSize: self.consoleFontSize, weight: UIFontWeightRegular)
    }()
    
    lazy var consoleEnabled: Bool = { [unowned self] in
        guard let enabled = self.boolForKey(Key.Console.Enabled)
            else { return Default.Enabled }
        return enabled
        }()
    
    lazy var consoleAutoStart: Bool = { [unowned self] in
        guard let autoStart = self.boolForKey(Key.Console.AutoStart)
            else { return Default.AutoStart }
        return autoStart
        }()
    
    lazy var shakeGestureEnabled: Bool = { [unowned self] in
        guard let shake = self.boolForKey(Key.Console.ShakeGesture)
            else { return Default.ShakeGesture }
        return shake
        }()
    
    lazy var consoleBackColor: UIColor = { [unowned self] in
        guard let color = self.colorForKey(Key.Console.BackColor)
            else { return Default.BackColor }
        return color
        }()
    
    lazy var consoleTextColor: UIColor = { [unowned self] in
        guard let color = self.colorForKey(Key.Console.TextColor)
            else { return Default.TextColor }
        return color
        }()
    
    fileprivate lazy var consoleFontSize: CGFloat = { [unowned self] in
        guard let fontSize = self.numberForKey(Key.Console.FontSize)
            else { return Default.FontSize }
        return fontSize
        }()
    
    lazy var consoleRowHeight: CGFloat = { [unowned self] in
        guard let rowHeight = self.numberForKey(Key.Console.RowHeight)
            else { return Default.RowHeight }
        return rowHeight
        }()
    
    lazy var consoleOpacity: CGFloat = { [unowned self] in
        guard let opacity = self.numberForKey(Key.Console.Opacity)
            else { return Default.Opacity }
        return opacity
        }()
    
    // MARK: Helpers
    
    private func boolForKey(_ key: String) -> Bool? {
        guard let
            settings = consoleSettings,
            let bool = settings[key] as? Bool
            else { return nil }
        return bool
    }
    
    private func numberForKey(_ key: String) -> CGFloat? {
        guard let
            settings = consoleSettings,
            let number = settings[key] as? CGFloat
            else { return nil }
        return number
    }
    
    private func colorForKey(_ key: String) -> UIColor? {
        guard let
            settings = consoleSettings,
            let hex = settings[key] as? String
            else { return nil }
        let color = colorFromHexString(hex)
        return color
    }
    
    private func colorFromHexString(_ hex: String) -> UIColor? {
        let scanner = Scanner(string: hex)
        var hexValue: UInt32 = 0
        if scanner.scanHexInt32(&hexValue) {
            let red   = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((hexValue & 0x00FF00) >> 8) / 255.0
            let blue  = CGFloat((hexValue & 0x0000FF)) / 255.0
            let color = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
            return color
        } else { return nil }
    }
    
}
