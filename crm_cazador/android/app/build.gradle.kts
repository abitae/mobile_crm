import java.util.Properties
import java.io.FileInputStream
plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
// Buscar key.properties en android/key.properties o en la raíz del proyecto
val keystorePropertiesFile = rootProject.file("key.properties").takeIf { it.exists() }
    ?: rootProject.file("../key.properties").takeIf { it.exists() }
    ?: file("key.properties").takeIf { it.exists() }

if (keystorePropertiesFile != null && keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    println("✅ Keystore properties cargadas desde: ${keystorePropertiesFile.absolutePath}")
} else {
    println("⚠️ key.properties no encontrado. Usando firma de debug para release.")
}

android {
    namespace = "com.abitae.crm_cazador"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
        // Configuraciones para evitar problemas de compilación
        freeCompilerArgs += listOf(
            "-Xjvm-default=all",
            "-Xopt-in=kotlin.RequiresOptIn"
        )
    }

    defaultConfig {
        applicationId = "com.abitae.crm_cazador"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Configuraciones para depuración
        multiDexEnabled = true
    }
    signingConfigs {
        if (keystorePropertiesFile != null && keystorePropertiesFile.exists()) {
            val keyAlias = keystoreProperties["keyAlias"] as String?
            val keyPassword = keystoreProperties["keyPassword"] as String?
            val storeFile = keystoreProperties["storeFile"] as String?
            val storePassword = keystoreProperties["storePassword"] as String?
            
            if (keyAlias != null && keyPassword != null && storeFile != null && storePassword != null) {
                // Resolver la ruta del keystore (puede ser relativa o absoluta)
                val keystorePath = if (storeFile.startsWith("/") || storeFile.contains(":\\")) {
                    // Ruta absoluta
                    file(storeFile)
                } else {
                    // Ruta relativa desde key.properties
                    keystorePropertiesFile.parentFile?.resolve(storeFile)?.takeIf { it.exists() }
                        ?: rootProject.file(storeFile).takeIf { it.exists() }
                        ?: file(storeFile)
                }
                
                if (keystorePath.exists()) {
                    create("release") {
                        this.keyAlias = keyAlias
                        this.keyPassword = keyPassword
                        this.storeFile = keystorePath
                        this.storePassword = storePassword
                    }
                    println("✅ Configuración de firma release creada con keystore: ${keystorePath.absolutePath}")
                } else {
                    println("⚠️ Keystore no encontrado en: ${keystorePath.absolutePath}")
                }
            } else {
                println("⚠️ Propiedades de keystore incompletas en key.properties")
            }
        }
    }
    buildTypes {
        getByName("debug") {
            // Configuraciones optimizadas para depuración
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-debug"
            isDebuggable = true
            isMinifyEnabled = false
            isShrinkResources = false
            // Sin optimizaciones para compilación más rápida
        }
        
        getByName("profile") {
            // Configuraciones para profile builds
            applicationIdSuffix = ".profile"
            versionNameSuffix = "-profile"
            isDebuggable = false
            isMinifyEnabled = false
            isShrinkResources = false
        }
        
        getByName("release") {
            // Configuraciones para release
            isDebuggable = false
            isMinifyEnabled = true
            isShrinkResources = true
            // Configuración de ProGuard/R8 (solo para release)
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = if (keystorePropertiesFile != null && 
                keystorePropertiesFile.exists() && 
                signingConfigs.findByName("release") != null) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
    
    // Configuraciones de packaging
    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
            excludes += "META-INF/DEPENDENCIES"
            excludes += "META-INF/LICENSE"
            excludes += "META-INF/LICENSE.txt"
            excludes += "META-INF/license.txt"
            excludes += "META-INF/NOTICE"
            excludes += "META-INF/NOTICE.txt"
            excludes += "META-INF/notice.txt"
            excludes += "META-INF/ASL2.0"
            excludes += "META-INF/*.kotlin_module"
        }
    }
    
    // Configuraciones de lint
    lint {
        checkReleaseBuilds = false
        abortOnError = false
        disable.add("InvalidPackage")
    }
}

flutter {
    source = "../.."
}
