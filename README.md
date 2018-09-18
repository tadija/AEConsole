# AEConsole
**Customizable Console UI overlay with debug log on top of your iOS App**

[![Language Swift 4.2](https://img.shields.io/badge/Language-Swift%204.2-orange.svg?style=flat)](https://swift.org)
[![Platforms iOS](https://img.shields.io/badge/Platforms-iOS-lightgray.svg?style=flat)](http://www.apple.com)
[![License MIT](https://img.shields.io/badge/License-MIT-lightgrey.svg?style=flat)](https://github.com/tadija/AELog/blob/master/LICENSE)

[![CocoaPods Version](https://img.shields.io/cocoapods/v/AEConsole.svg?style=flat)](https://cocoapods.org/pods/AEConsole)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

**AEConsole** is built on top of [AELog](https://github.com/tadija/AELog), so you should probably see that first.
> I wanted to see what's happening 'under the hood' while testing some app AFK (ex. outside).
> Then I made it possible. Hope you'll like it too, happy coding!

![AEConsole](http://tadija.net/projects/AEConsole/AEConsole.png)

## Index
- [Features](#features)
- [Usage](#usage)
- [Quick Help](#quick-help)
- [Installation](#installation)
- [License](#license)

## Features
- **All the things** from [AELog](https://github.com/tadija/AELog) plus:
- Console UI overlay **on top of your App**
- **Debug log on device** in real time
- **Automatic row height** for all log lines
- **Forward touches** to your App
- **Shake to toggle** Console UI
- **Filter log** to find exactly what you need
- **Export log** to file if you need it for later
- **Share log file** easily via system sharing sheet
- **Customize look** as you like it

## Usage

Calling `Console.shared.configure(in: window)` will add `Console.View` as a subview to your App's window and make it hidden by default.
Whenever you need Console UI, you just make a shake gesture and it's there! When you no longer need it, shake again and it's gone.

The rest is up to [AELog's](https://github.com/tadija/AELog) logging functionality. Whatever is logged with it, will show up in `Console.View`.

```swift
// MARK: - Console configuration

func application(_ application: UIApplication,
                 didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
{
    /// - Note: Access Console settings
    let settings = Console.shared.settings

    /// - Note: Customize Console settings like this, these are defaults:
    settings.isShakeGestureEnabled = true
    settings.backColor = UIColor.black
    settings.textColor = UIColor.white
    settings.fontSize = 12.0
    settings.rowSpacing = 4.0
    settings.opacity = 0.7

    /// - Note: Configure Console in app window (it's recommended to skip this for public release)
    Console.shared.configure(in: window)

    /// - Note: Log something with AELog
    aelog()

    return true
}
```

```swift
// MARK: - Additional Console API

/// - Note: Check if Console is hidden
Console.shared.isHidden

/// - Note: Toggle Console visibility
Console.shared.toggle()

/// - Note: Add any log line manually
Console.shared.addLogLine(line: "Hello!")

/// - Note: Export log file manually
Console.shared.exportLogFile { (fileURL) in
    do {
        let url = try fileURL()
        /// - Note: do something with a log file at given file URL...
    } catch {
        print(error)
    }
}
```

## Quick Help

This should explain all the features of Console UI:

![AEConsole](http://tadija.net/projects/AEConsole/AEConsole-QuickHelp.png)

Feature | Description
------------ | -------------
Export Log | will make `AELog_{timestamp}.txt` file in Application Documents directory and present sharing sheet.
Filter Log | filter is not case sensitive.
Toggle Toolbar | works for both filter and menu toolbars simultaneously.
Toggle Forward Touches | when active you can interact with your App, otherwise you can interact with the log.
Toggle Auto Follow | when active it will automatically scroll to the new log lines, otherwise it will stay put.
Clear Log | you can't undo this.
Pan Gesture over Menu Toolbar | left is more transparent, right is more opaque.

## Installation

- [Swift Package Manager](https://swift.org/package-manager/):

    ```
    .Package(url: "https://github.com/tadija/AEConsole.git", majorVersion: 0)
    ```
  
- [Carthage](https://github.com/Carthage/Carthage):

	```ogdl
	github "tadija/AEConsole"
	```
	
- [CocoaPods](http://cocoapods.org/):

	```ruby
	pod 'AEConsole'
	```

## License
AEConsole is released under the MIT license. See [LICENSE](LICENSE) for details.
