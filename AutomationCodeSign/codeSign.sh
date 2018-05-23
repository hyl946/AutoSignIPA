#!/bin/sh

cd ./

security cms -D -i "embedded.mobileprovision" > "entitlements_full.plist"

/usr/libexec/PlistBuddy -x -c 'Print:Entitlements' entitlements_full.plist > entitlements.plist

rm -r dnf.app/_CodeSignature

/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.esurfingpay.bestpayDev" dnf.app/info.plist

cp embedded.mobileprovision dnf.app/

#递归赋权限
chmod -R +x dnf.app

/usr/bin/codesign --continue -f -s "iPhone Distribution: ChinaTelecom Bestpay Co. Ltd" --entitlements "entitlements.plist"  "dnf.app"

mkDir Payload

cp -r dnf.app Payload/

zip -r dnf.zip Payload

cp dnf.zip dnf.ipa

rm -r dnf.zip
rm -r entitlements_full.plist
rm -r entitlements.plist
rm -r Payload



#  Created by Loren on 2018/2/24.
#  Copyright © 2018年 Loren. All rights reserved.
