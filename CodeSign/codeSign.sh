#!/bin/sh

#签名framework dylib库
function codesignFrameworkDylib()
{
    for file in `ls "$1"`;
    do
        extension="${file#*.}"
        if [[ -d "$1/$file" ]]; then
            if [[ "$extension" == "framework" ]]; then
                /usr/bin/codesign --force --sign "iPhone Distribution: ChinaTelecom Bestpay Co. Ltd" "$1/$file"
            else
                codesignFrameworkDylib "$1/$file"
            fi
        elif [[ -f "$1/$file" ]]; then

            if [[ "$extension" == "dylib" ]]; then
                /usr/bin/codesign --force --sign "iPhone Distribution: ChinaTelecom Bestpay Co. Ltd" "$1/$file"
            fi
        fi
    done
}
#重签整个APP
function codesign()
{
    codesignFrameworkDylib "$1"
    /usr/bin/codesign --continue -f -s "iPhone Distribution: ChinaTelecom Bestpay Co. Ltd" --entitlements "entitlements.plist"  "$PAYLOAD_APP_PATH"
}

function installApp()
{
    ideviceinstaller -i "$1"
}
function star()
{
cd ./
#ipa路径
TARGET_IPA_PATH=$(find "TargetIPA" -type f | grep ".ipa$" | head -n 1)

#ipa 名字
TARGET_IPA_NAME=$(basename "$TARGET_IPA_PATH" .ipa)

#解压
unzip -u "$TARGET_IPA_PATH" -d "$TARGET_IPA_NAME"


#解压的App路径
UNZIP_APP_PATH=$(find  "$TARGET_IPA_NAME""/Payload"  -name  "*.app" | head -n 1)
#app名字
TARGET_APP_NAME=$(basename "$UNZIP_APP_PATH" .app)

rm -rf "Payload"
mkdir "Payload"
cp -r "$UNZIP_APP_PATH" "Payload/"

#Payload文件内的App路径
PAYLOAD_APP_PATH=$(find  "Payload"  -name  "*.app" | head -n 1)

security cms -D -i "embedded.mobileprovision" > "entitlements_full.plist"
#生成plist
/usr/libexec/PlistBuddy -x -c 'Print:Entitlements' entitlements_full.plist > entitlements.plist
#删除旧的签名
rm -rf "$PAYLOAD_APP_PATH""/_CodeSignature"
rm -rf "$PAYLOAD_APP_PATH""/PlugIns"
rm -rf "$PAYLOAD_APP_PATH""/Watch"
#设置bundle ID
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.esurfingpay.bestpayDev" "$PAYLOAD_APP_PATH""/info.plist"

cp embedded.mobileprovision "$PAYLOAD_APP_PATH"

#递归赋权限
chmod -R +x "$PAYLOAD_APP_PATH"
#证书
codesign "$PAYLOAD_APP_PATH"
#zip -r "$TARGET_APP_NAME"".ipa" "Payload"

#clear
#r把路径下的文件递归删除 f忽略不存的文件
rm -rf entitlements_full.plist
rm -rf entitlements.plist
#rm -r Payload
rm -rf "$TARGET_IPA_NAME"

installApp "Payload/$TARGET_APP_NAME"".app"
}

star
#  Created by Loren on 2018/2/24.
#  Copyright © 2018年 Loren. All rights reserved.
