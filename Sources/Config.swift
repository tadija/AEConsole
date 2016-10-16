//
// Config.swift
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

import UIKit

/**
    Helper for accessing settings from the external file.

    Create `AEConsole.plist` dictionary file and add it to your target.
    Alternative is to add `AEConsole` dictionary inside existing `Info.plist` file.

    There is `Key` struct which contains possible keys for all settings.
*/
public class Config {
    
    // MARK: - Constants
    
    /// Setting keys which can be used in `AEConsole` dictionary.
    public struct Key {
        /// Boolean - Console UI enabled flag (defaults to `NO`)
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
    
    private struct Default {
        static let Enabled = false
        static let AutoStart = false
        static let ShakeGesture = true
        static let BackColor = UIColor.black
        static let TextColor = UIColor.white
        static let FontSize: CGFloat = 12.0
        static let RowHeight: CGFloat = 14.0
        static let Opacity: CGFloat = 0.7
    }
    
    // MARK: - Properties
    
    static let shared = Config()
    
    lazy var textColorWithOpacity: UIColor = { [unowned self] in
        self.textColor.withAlphaComponent(Default.Opacity)
    }()
    
    /// Contents of AEConsole settings (AEConsole.plist file or AEConsole dictionary from Info.plist)
    private lazy var data: [String : AnyObject]? = {
        guard let
            path = Bundle.main.path(forResource: "AEConsole", ofType: "plist"),
            let data = NSDictionary(contentsOfFile: path) as? [String : AnyObject]
        else { return self.alternateData }
        return data
    }()
    
    private lazy var alternateData: [String : AnyObject]? = {
        guard let data = Bundle.main.infoDictionary?["AEConsole"] as? [String : AnyObject]
        else { return nil }
        return data
    }()
    
    // MARK: - Settings
    
    lazy var consoleFont: UIFont = {
        return UIFont.monospacedDigitSystemFont(ofSize: self.fontSize, weight: UIFontWeightRegular)
    }()
    
    lazy var isEnabled: Bool = { [unowned self] in
        guard let enabled = self.getBool(with: Key.Enabled)
        else { return Default.Enabled }
        return enabled
    }()
    
    lazy var isAutoStartEnabled: Bool = { [unowned self] in
        guard let autoStart = self.getBool(with: Key.AutoStart)
        else { return Default.AutoStart }
        return autoStart
    }()
    
    lazy var isShakeGestureEnabled: Bool = { [unowned self] in
        guard let shake = self.getBool(with: Key.ShakeGesture)
        else { return Default.ShakeGesture }
        return shake
    }()
    
    lazy var backColor: UIColor = { [unowned self] in
        guard let color = self.getColor(with: Key.BackColor)
        else { return Default.BackColor }
        return color
    }()
    
    lazy var textColor: UIColor = { [unowned self] in
        guard let color = self.getColor(with: Key.TextColor)
        else { return Default.TextColor }
        return color
    }()
    
    lazy var fontSize: CGFloat = { [unowned self] in
        guard let fontSize = self.getNumber(with: Key.FontSize)
        else { return Default.FontSize }
        return fontSize
    }()
    
    lazy var rowHeight: CGFloat = { [unowned self] in
        guard let rowHeight = self.getNumber(with: Key.RowHeight)
        else { return Default.RowHeight }
        return rowHeight
    }()
    
    lazy var opacity: CGFloat = { [unowned self] in
        guard let opacity = self.getNumber(with: Key.Opacity)
        else { return Default.Opacity }
        return opacity
    }()
    
    // MARK: - Helpers
    
    private func getBool(with key: String) -> Bool? {
        guard let
            data = self.data,
            let bool = data[key] as? Bool
        else { return nil }
        return bool
    }
    
    private func getNumber(with key: String) -> CGFloat? {
        guard let
            data = self.data,
            let number = data[key] as? CGFloat
        else { return nil }
        return number
    }
    
    private func getColor(with key: String) -> UIColor? {
        guard let
            data = self.data,
            let hex = data[key] as? String
        else { return nil }
        let color = getColor(from: hex)
        return color
    }
    
    private func getColor(from hex: String) -> UIColor? {
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
