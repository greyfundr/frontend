plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.greyfundr"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
<<<<<<< HEAD
<<<<<<< HEAD
        isCoreLibraryDesugaringEnabled = true
=======
>>>>>>> ce6d2d2 (integration + ui)
=======
        isCoreLibraryDesugaringEnabled = true
>>>>>>> 5dd47ca (added gradle access)
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.greyfundr"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
<<<<<<< HEAD
<<<<<<< HEAD

        multiDexEnabled = true
=======
>>>>>>> ce6d2d2 (integration + ui)
=======

        multiDexEnabled = true
>>>>>>> 5dd47ca (added gradle access)
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> 5dd47ca (added gradle access)
// Add this block at the bottom (outside android/flutter blocks)
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")  // Latest stable as of Feb 2026
}
<<<<<<< HEAD
=======
>>>>>>> ce6d2d2 (integration + ui)
=======
>>>>>>> 5dd47ca (added gradle access)
