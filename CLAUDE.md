# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Android
./gradlew :androidApp:assembleDebug          # Build Android debug APK
./gradlew :androidApp:installDebug           # Build and install on connected device/emulator

# Shared module
./gradlew :shared:build                      # Build shared KMP module
./gradlew :shared:linkDebugFrameworkIosSimulatorArm64  # Build iOS framework for simulator

# iOS
# Open iosApp/iosApp.xcodeproj in Xcode and build from there
# The Xcode project embeds the shared framework automatically
```

## Architecture

This is a Kotlin Multiplatform (KMP) project with native UI for both Android (Jetpack Compose) and iOS (SwiftUI). The app displays museum objects from The Metropolitan Museum of Art Collection API.

### Module Structure

- **shared/** - KMP module containing shared business logic for Android and iOS (uses `com.android.kotlin.multiplatform.library` plugin)
- **androidApp/** - Android app with Jetpack Compose UI (pure Android app, not KMP)
- **iosApp/** - iOS app with SwiftUI (Xcode project)

### Gradle Plugin Configuration

This project uses AGP 9.0+ with the new KMP DSL:
- **shared module**: Uses `com.android.kotlin.multiplatform.library` plugin with `kotlin { androidLibrary { } }` DSL
- **androidApp module**: Uses standard `com.android.application` plugin (not combined with KMP plugin)

### Shared Module Architecture

```
shared/src/commonMain/kotlin/com/jetbrains/kmpapp/
├── data/
│   ├── MuseumApi.kt          # API interface and Ktor implementation
│   ├── MuseumObject.kt       # Data model
│   ├── MuseumRepository.kt   # Repository pattern with Flow
│   └── MuseumStorage.kt      # In-memory storage interface
├── di/
│   └── Koin.kt               # DI setup with Koin
└── screens/
    ├── ListViewModel.kt      # Shared ViewModel using KMP-ObservableViewModel
    └── DetailViewModel.kt
```

### Key Patterns

- **ViewModels** extend `ViewModel` from KMP-ObservableViewModel library for cross-platform use
- **@NativeCoroutinesState** annotation on StateFlow properties enables SwiftUI observation
- **Koin** for dependency injection - `initKoin()` called from both Android and iOS entry points
- **Repository** initializes data fetch in its `initialize()` method, called during DI setup

### Platform-Specific Code

- Android HTTP client: Ktor with OkHttp engine (`shared/src/androidMain/`)
- iOS HTTP client: Ktor with Darwin engine (`shared/src/iosMain/`)
- iOS needs `KoinDependencies.kt` to expose Koin dependencies to Swift

### iOS Integration

The iOS app imports the `Shared` framework and uses `KMPObservableViewModel.swift` wrapper to observe KMP ViewModels in SwiftUI views.
