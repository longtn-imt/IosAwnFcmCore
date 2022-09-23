#!/bin/sh

#  framework-build.sh
#  Pods
#
#  Created by Rafael Setragni on 23/09/22.
#

xcodebuild archive -scheme IosAwnFcmCore -destination "generic/platform=iOS" -archivePath build/IosAwnFcmCore-iOS SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild archive -scheme IosAwnFcmCore -destination "generic/platform=iOS Simulator" -archivePath build/IosAwnFcmCore-sim SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES


xcodebuild -create-xcframework -framework build/IosAwnFcmCore-iOS.xcarchive/Products/Library/Frameworks/IosAwnFcmCore.framework -framework build/IosAwnFcmCore-sim.xcarchive/Products/Library/Frameworks/IosAwnFcmCore.framework -output build/IosAwnFcmCore.xcframework
