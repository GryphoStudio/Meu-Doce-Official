pluginManagement {
    includeBuild("../flutter")
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()

        // 🔧 Necessário para o Flutter encontrar o loader plugin
        val flutterSdkPath = 
            System.getenv("FLUTTER_ROOT") 
                ?: "../flutter"
        maven { url = uri("$flutterSdkPath/bin/cache/artifacts/engine") }
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.6.1" apply false
    id("org.jetbrains.kotlin.android") version "1.9.24" apply false
    id("com.google.gms.google-services") version "4.4.2" apply false
}

include(":app")
