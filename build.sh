#!/bin/bash

# Создаем директорию для сборки
mkdir -p build

# Компилируем Swift файлы
swiftc -o build/LaunchpadAdder \
    LaunchpadAdder/AppDelegate.swift \
    LaunchpadAdder/DropView.swift \
    LaunchpadAdder/main.swift \
    -framework Cocoa \
    -framework UniformTypeIdentifiers

# Создаем структуру приложения
mkdir -p "build/LaunchpadAdder.app/Contents/MacOS"
mkdir -p "build/LaunchpadAdder.app/Contents/Resources"

# Копируем исполняемый файл
cp build/LaunchpadAdder "build/LaunchpadAdder.app/Contents/MacOS/"

# Копируем иконку приложения
cp "/Volumes/SSD/Developing/Mac/DsItZZF8OYYgG3o8G1mYZxbNYzShs6KS.icns" "build/LaunchpadAdder.app/Contents/Resources/AppIcon.icns"

# Создаем Info.plist
cat > "build/LaunchpadAdder.app/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>LaunchpadAdder</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.seidenov.LaunchpadAdder</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>LaunchpadAdder</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.13</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>LSUIElement</key>
    <false/>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2025 seidenov. Все права защищены.</string>
</dict>
</plist>
EOF

echo "Сборка успешно завершена. Приложение находится в директории build/LaunchpadAdder.app" 