plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.nextdish_app"
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
        applicationId = "com.example.nextdish_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Menggunakan debug key untuk sementara (sesuai kode asli Anda)
            signingConfig = signingConfigs.getByName("debug")
            
            // --- PERBAIKAN 1: Konfigurasi ProGuard/R8 ---
            // Mengaktifkan minification (pengecilan kode)
            isMinifyEnabled = true 
            // Mengaktifkan penyusutan resource
            isShrinkResources = true 
            // Memberitahu R8 untuk membaca file aturan proguard
            proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

// --- PERBAIKAN 2: Menambahkan Dependency Manual ---
dependencies {
    // Menambahkan okhttp3 agar R8 tidak error karena kelas hilang
    implementation("com.squareup.okhttp3:okhttp:4.9.3")
}