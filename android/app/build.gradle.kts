import java.util.Base64
import java.util.Properties

// Release signing comes from android/key.properties, which is gitignored
// (template: android/key.properties.example). Without it, release builds
// fall back to the debug key so `flutter run --release` still works.
val keystoreFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystoreFile.exists()) keystoreFile.inputStream().use { load(it) }
}
val hasReleaseKeystore = keystoreProperties.isNotEmpty()

// Brand registry. Keep in sync with brand_catalog.dart, BrandSwitcher.kt
// and AppDelegate.swift.
// Append-only: never rename or remove a key a user may have enabled.
val brandNames = linkedMapOf(
    "aurora" to "AURORA",
    "nova" to "NOVA",
    "pulse" to "PULSE",
    "orbit" to "ORBIT",
)
val brandIcons = listOf("rocket", "star", "heart")

// Primary pair for this build. Set BRAND / BRAND_ICON in CI to change it.
val brand = System.getenv("BRAND") ?: "aurora"
val brandIcon = System.getenv("BRAND_ICON") ?: "rocket"
require(brand in brandNames) { "Unknown BRAND: $brand" }
require(brandIcon in brandIcons) { "Unknown BRAND_ICON: $brandIcon" }

// DISTRIBUTION is read from the Flutter --dart-define values, so the
// manifest and lib/core/config/app_env.dart always agree.
//   store:  App Store / Play; runtime switching between bundled keys.
//   direct: APK outside Play; the custom name and icon in src/custom/res
//           are baked in and only .AliasCustom is enabled.
val dartDefines = (project.findProperty("dart-defines") as String?)
    ?.split(",")
    ?.map { String(Base64.getDecoder().decode(it)).split("=", limit = 2) }
    ?.filter { it.size == 2 }
    ?.associate { it[0] to it[1] }
    .orEmpty()
val distribution = dartDefines["DISTRIBUTION"] ?: "store"
require(distribution in listOf("store", "direct")) { "Unknown DISTRIBUTION: $distribution" }
val direct = distribution == "direct"

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.brandswitcher"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.brandswitcher"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        buildConfigField("String", "PRIMARY_BRAND", "\"$brand\"")
        buildConfigField("String", "PRIMARY_ICON", "\"$brandIcon\"")
        resValue("string", "brand_main", brandNames.getValue(brand))
        // Application label/icon show in Settings > Apps.
        manifestPlaceholders["appLabel"] = if (direct) "@string/brand_custom" else "@string/brand_main"
        manifestPlaceholders["primaryIcon"] = if (direct) "@mipmap/ic_custom" else "@mipmap/ic_$brandIcon"
        manifestPlaceholders["primaryRoundIcon"] =
            if (direct) "@mipmap/ic_custom" else "@mipmap/ic_${brandIcon}_round"
        // One activity-alias per name x icon; only the primary pair is enabled.
        // Direct builds enable .AliasCustom instead.
        brandNames.keys.forEach { n ->
            brandIcons.forEach { i ->
                manifestPlaceholders["enabled_${n}_$i"] =
                    (!direct && n == brand && i == brandIcon).toString()
            }
        }
        manifestPlaceholders["enabled_custom"] = direct.toString()
        // Store and direct builds can sit side by side on a test device.
        if (direct) applicationIdSuffix = ".direct"
    }

    // ic_custom / brand_custom for direct builds. Always on the
    // resource path because the manifest references them in every build.
    sourceSets["main"].res.srcDir("src/custom/res")

    buildFeatures {
        buildConfig = true
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName(if (hasReleaseKeystore) "release" else "debug")
        }
    }
}

flutter {
    source = "../.."
}
