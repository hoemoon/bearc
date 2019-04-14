build:
	swift build -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.14"

xcode:
	swift package generate-xcodeproj --xcconfig-overrides settings.xcconfig
