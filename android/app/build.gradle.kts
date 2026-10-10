import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseSigningFile = rootProject.file("key.properties")
val releaseSigning = Properties().apply {
    if (releaseSigningFile.exists()) releaseSigningFile.inputStream().use { load(it) }
}

android {
    namespace = "cn.mengxw.breast_milk"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "cn.mengxw.breast_milk"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        // Always attach a complete signing configuration. Without credentials,
        // AGP validates this deliberately absent keystore instead of producing
        // an unsigned artifact through an unrecognised/custom task name.
        create("release") {
            val missing = "release-signing-not-configured"
            keyAlias = releaseSigning.getProperty("keyAlias")?.takeIf { it.isNotBlank() } ?: missing
            keyPassword = releaseSigning.getProperty("keyPassword")?.takeIf { it.isNotBlank() } ?: missing
            storePassword = releaseSigning.getProperty("storePassword")?.takeIf { it.isNotBlank() } ?: missing
            storeFile = releaseSigning.getProperty("storeFile")?.takeIf { it.isNotBlank() }
                ?.let { rootProject.file(it) }
                ?: rootProject.file(".missing-release-signing/keystore.jks")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }

    lint {
        abortOnError = true
        checkReleaseBuilds = true
    }

}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
    implementation("androidx.core:core-splashscreen:1.0.1")
    implementation(files("libs/printer-lib-3.5.8.aar"))
}

flutter {
    source = "../.."
}

// Debug/lint tasks remain available without release credentials.
gradle.taskGraph.whenReady {
    val buildsRelease = allTasks.any {
        it.project == project && (it.name.startsWith("assemble") || it.name.startsWith("bundle") ||
            it.name.startsWith("package")) && it.name.contains("Release")
    }
    if (buildsRelease) {
        require(releaseSigningFile.exists()) { "Release signing requires android/key.properties; see android/key.properties.example" }
        for (key in listOf("storeFile", "storePassword", "keyAlias", "keyPassword")) {
            require(!releaseSigning.getProperty(key).isNullOrBlank()) { "Missing release signing property: $key" }
        }
    }
}
