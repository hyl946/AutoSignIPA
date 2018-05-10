#!/bin/sh

cd ./
#ipa路径
TARGET_IPA_PATH=$(find "TargetIPA" -type f | grep ".ipa$" | head -n 1)

#ipa 名字
TARGET_IPA_NAME=$(basename "$TARGET_IPA_PATH" .ipa)

#解压
unzip -u "$TARGET_IPA_PATH" -d "$TARGET_IPA_NAME"


#解压的App路径
UNZIP_APP_PATH=$(find  "$TARGET_IPA_NAME""/Payload"  -name  "*.app")
#app名字
TARGET_APP_NAME=$(basename "$UNZIP_APP_PATH" .app)

mkdir "Payload"
cp -rf "$UNZIP_APP_PATH" "Payload/"

#Payload文件内的App路径
PAYLOAD_APP_PATH=$(find  "Payload"  -name  "*.app")

security cms -D -i "embedded.mobileprovision" > "entitlements_full.plist"
#生成plist
/usr/libexec/PlistBuddy -x -c 'Print:Entitlements' entitlements_full.plist > entitlements.plist
#删除旧的签名
rm -r "$PAYLOAD_APP_PATH""/_CodeSignature"
#设置bundle ID
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.esurfingpay.bestpayDev" "$PAYLOAD_APP_PATH""/info.plist"

cp embedded.mobileprovision "$PAYLOAD_APP_PATH"

#递归赋权限
chmod -R +x "$PAYLOAD_APP_PATH"
#证书
/usr/bin/codesign --continue -f -s "iPhone Distribution: ChinaTelecom Bestpay Co. Ltd" --entitlements "entitlements.plist"  "$PAYLOAD_APP_PATH"

zip -r "$TARGET_APP_NAME"".zip" Payload

mv "$TARGET_APP_NAME"".zip" "$TARGET_APP_NAME"".ipa"

#clear
rm -r entitlements_full.plist
rm -r entitlements.plist
rm -r Payload
rm -r "$TARGET_IPA_NAME"

ideviceinstaller -i "$TARGET_APP_NAME"".ipa"


#  Created by Loren on 2018/2/24.
#  Copyright © 2018年 Loren. All rights reserved.
