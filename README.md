# IosAwnFcmCore

[![CI Status](https://img.shields.io/travis/Rafael Setragni/IosAwnFcmCore.svg?style=flat)](https://travis-ci.org/Rafael Setragni/IosAwnFcmCore)
[![Version](https://img.shields.io/cocoapods/v/IosAwnFcmCore.svg?style=flat)](https://cocoapods.org/pods/IosAwnFcmCore)
[![License](https://img.shields.io/cocoapods/l/IosAwnFcmCore.svg?style=flat)](https://cocoapods.org/pods/IosAwnFcmCore)
[![Platform](https://img.shields.io/cocoapods/p/IosAwnFcmCore.svg?style=flat)](https://cocoapods.org/pods/IosAwnFcmCore)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

IosAwnFcmCore is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'IosAwnFcmCore'
```

## Author

Rafael Setragni, 40064496+rafaelsetragni@users.noreply.github.com

## License

IosAwnFcmCore is available under the MIT license. See the LICENSE file for more info.


xcodebuild archive -scheme IosAwnFcmCore -destination "generic/platform=iOS" -archivePath build/IosAwnFcmCore-iOS SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild archive -scheme IosAwnFcmCore -destination "generic/platform=iOS Simulator" -archivePath build/IosAwnFcmCore-sim SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild -create-xcframework -framework build/IosAwnFcmCore-iOS.xcarchive/Products/Library/Frameworks/IosAwnFcmCore.framework -framework build/IosAwnFcmCore-sim.xcarchive/Products/Library/Frameworks/IosAwnFcmCore.framework -output build/IosAwnFcmCore.xcframework
