build:
	swift build -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.12"

xcode:
	swift package generate-xcodeproj --xcconfig-overrides settings.xcconfig

install:
	install .build/x86_64-apple-macosx/debug/bearc /usr/local/bin