# iALT Installation Guide

# Requirements
CocoaPods: `sudo gem install cocoapods` \
XCode: Install from app store \
Mac computer \
iPhone \
Lightning cable to connect iphone to computer

# Installation
1. Clone the repository to your computer: `git clone https://github.com/aymather/iALT-iOS`
2. Install pods: `cd ./iALT-iOS && pod install`
3. Open project file with XCode: `open ./iALT.xcworkspace`

# How to run
1. Under "Targets -> Signing & Capabilities" you need to change the "Team". If no teams are available, you need to make one. Pretty sure this is managed via an iCloud account, which you can make for free pretty easily.
2. Plug in your iPhone.
3. In the top left there's a play button, to the right of that is a drop down menu, click it and find the iPhone you just connected (not the simulators).
4. Either press "play" button or "Cmd+r" to run.
