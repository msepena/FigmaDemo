# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

SwiftUI iOS app scaffolded by Xcode. Bundle id `com.test.FigmaDemo`, universal (iPhone + iPad), Swift 5.0, **iOS deployment target 26.4** (set deliberately — do not lower it without asking). The app currently consists of `FigmaDemoApp` (entry point) and a placeholder `ContentView`.

## Build & test

The project uses an `.xcodeproj` (no workspace, no SwiftPM manifest). Open `FigmaDemo.xcodeproj` in Xcode, or use `xcodebuild` from a shell with full Xcode selected (`sudo xcode-select -s /Applications/Xcode.app`). The bare Command Line Tools install does not include `xcodebuild`.

Common commands (scheme name matches the target, `FigmaDemo`):

```bash
# Build for simulator
xcodebuild -project FigmaDemo.xcodeproj -scheme FigmaDemo \
  -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run unit tests (FigmaDemoTests)
xcodebuild -project FigmaDemo.xcodeproj -scheme FigmaDemo \
  -destination 'platform=iOS Simulator,name=iPhone 16' test

# Run a single test (Swift Testing uses -only-testing:Target/Suite/test)
xcodebuild -project FigmaDemo.xcodeproj -scheme FigmaDemo \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:FigmaDemoTests/FigmaDemoTests/example test

# Run a single UI test (XCTest uses -only-testing:Target/Class/method)
xcodebuild -project FigmaDemo.xcodeproj -scheme FigmaDemo \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:FigmaDemoUITests/FigmaDemoUITests/testExample test
```

## Test frameworks (mixed)

- `FigmaDemoTests/` — **Swift Testing** (`import Testing`, `@Test`, `#expect`). New tests in this target should follow the same style.
- `FigmaDemoUITests/` — **XCTest** (`XCTestCase`, `XCUIApplication`). Required because Swift Testing does not cover UI automation.

Don't mix the two within a single target.
