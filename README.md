# AEConsole
**Customizable Console UI overlay with debug log on top of your iOS App**

[![Language Swift 3.0](https://img.shields.io/badge/Language-Swift%203.0-orange.svg?style=flat)](https://swift.org)
[![Platforms iOS](https://img.shields.io/badge/Platforms-iOS-lightgray.svg?style=flat)](http://www.apple.com)
[![License MIT](https://img.shields.io/badge/License-MIT-lightgrey.svg?style=flat)](https://github.com/tadija/AELog/blob/master/LICENSE)

[![CocoaPods Version](https://img.shields.io/cocoapods/v/AEConsole.svg?style=flat)](https://cocoapods.org/pods/AEConsole)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

**AEConsole** is built on top of [AELog](https://github.com/tadija/AELog), so you should probably see that first.
> I cought myself wanting to see what's happening 'under the hood' while testing some app AFK (ex. outside).  
> Then I made it possible. Hope you'll like it too, happy coding!

![AEConsole](http://tadija.net/projects/AEConsole/AEConsole.png)

## Index
- [Features](#features)
- [Usage](#usage)
	- [Settings](#settings)
	- [Quick Help](#quick-help)
- [Requirements](#requirements)
- [Installation](#installation)
- [License](#license)

## Features
- **All the things** from [AELog](https://github.com/tadija/AELog) plus:
- Console UI overlay **on top of your App**
- See **debug log directly on device** in real time
- **Forward touches** to your App
- **Shake to toggle** Console UI
- **Filter log** to find exactly what you need
- **Export log** to file if you need it for later
- **Customize look** as you like it
- Covered with [docs](http://cocoadocs.org/docsets/AEConsole)

## Usage

In order to enable **AEConsole** you should add this one-liner in your **AppDelegate's** `didFinishLaunchingWithOptions`:

```swift
AEConsole.launch(with: self)
```

If `AEConsole` is enabled, this will add `AEConsoleView` as a subview to your App's window and make it hidden by default.
Now, whenever you need Console UI, you just make a shake gesture and boom it's there! When you no longer need it, shake again and boom it's gone (there are no 'booms' really).

The rest is up to [AELog's](https://github.com/tadija/AELog) top-level logging function. Whatever is logged with `aelog()` it will show up in `AEConsoleView`.

In case you want to **toggle Console UI via code**, you can call `AEConsole.toggle()`, also you can **check its current state** via `AEConsole.hidden` property. So that's it about **API**, let's go through all the **customization settings**:

## Settings

1. Create **AEConsole.plist** file and add it to your target or create dictionary with name **AEConsole** in your existing **Info.plist** file.
2. Configure any setting the way you want *(don't forget to at least set `Enabled` to `YES` in order to make it work)*:

	Key | Type | Description
	------------ | ------------- | -------------
	Enabled | Boolean | Console UI enabled flag (defaults to `YES`)
	AutoStart | Boolean | Console UI visible on App start flag (defaults to `NO`)
	ShakeGesture | Boolean | Shake gesture enabled flag (defaults to `YES`)
	BackColor | String | Hex string for Console background color (defaults to `000000`)
	TextColor | String | Hex string for Console text color (defaults to `FFFFFF`)
	FontSize | Number | Console UI font size (defaults to `12`)
	RowHeight | Number | Console UI row height (defaults to `14`)
	Opacity | Number | Console UI opacity (defaults to `0.7`)

## Quick Help

This should explain all the features of Console UI:

![AEConsole](http://tadija.net/projects/AEConsole/AEConsole-QuickHelp.png)

Feature | Description
------------ | -------------
Export Log | will make `{timestamp}.aelog` file inside your App's Documents directory.
Filter Log | filter is not case sensitive.
Toggle Toolbar | works for both filter and menu toolbars simultaneously.
Toggle Forward Touches | when active you can interact with your App, otherwise you can interact with the log.
Toggle Auto Follow | when active it will automatically scroll to the new log lines, otherwise it will stay put.
Clear Log | you can't undo this.
Pan Gesture over Menu Toolbar | left is more transparent, right is more opaque.
	
## Requirements
- Xcode 8.0+
- iOS 9.0+

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