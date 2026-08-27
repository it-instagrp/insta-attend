import java.util.Properties
import java.io.FileInputStream
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")

    // FlutterFire
    id("com.google.gms.google-services")

    id("org.jetbrains.kotlin.android")

    // Flutter plugin
    id("dev.flutter.flutter-gradle-plugin")
}

// Load keystore.properties
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.nextechvision.insta_attend"

    compileSdk = 36
    ndkVersion = "28.2.13676358"

    defaultConfig {
        applicationId = "com.nextechvision.insta_attend"
        manifestPlaceholders["appLabel"] = "Insta Attend"

        minSdk = 24
        targetSdk = 36

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Environment flavors
    flavorDimensions += "environment"

    productFlavors {
        create("qa") {
            dimension = "environment"

            // TEST application ID
            applicationIdSuffix = ".test"
            manifestPlaceholders["appLabel"] = "Insta Attend Test"

            // Example: 1.1.0-test
            versionNameSuffix = "-test"
        }

        create("prod") {
            dimension = "environment"
            manifestPlaceholders["appLabel"] = "Insta Attend"

            // Production keeps the original application ID
            // com.nextechvision.insta_attend
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    signingConfigs {
        if (System.getenv("CI").toBoolean() || keystorePropertiesFile.exists()) {
            create("release") {
                if (System.getenv("CI").toBoolean()) {
                    storeFile = file(System.getenv("CM_KEYSTORE_PATH"))
                    storePassword = System.getenv("CM_KEYSTORE_PASSWORD")
                    keyAlias = System.getenv("CM_KEY_ALIAS")
                    keyPassword = System.getenv("CM_KEY_PASSWORD")
                } else {
                    storeFile = file(keystoreProperties["storeFile"] as String)
                    storePassword = keystoreProperties["storePassword"] as String
                    keyAlias = keystoreProperties["keyAlias"] as String
                    keyPassword = keystoreProperties["keyPassword"] as String
                }
            }
        }
    }

    buildTypes {
        getByName("release") {
            if (System.getenv("CI").toBoolean() || keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("release")
            }

            isMinifyEnabled = true
            isShrinkResources = true

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

subprojects {
    afterEvaluate {
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            compilerOptions {
                jvmTarget.set(JvmTarget.JVM_17)
            }
        }
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Move build directory outside android/
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()

rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory =
        newBuildDir.dir(project.name)

    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}
