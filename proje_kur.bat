@echo off
chcp 65001 >nul
echo RestoPOS projesi olusturuluyor...

mkdir RestoPOS\.github\workflows
mkdir RestoPOS\app\src\main\java\com\example\restopos\ui
mkdir RestoPOS\app\src\main\mipmap

:: 1. Workflow
(
echo name: Build Android APK
echo on:
echo   push:
echo     branches: [ "main", "master" ]
echo   workflow_dispatch:
echo jobs:
echo   build:
echo     runs-on: ubuntu-latest
echo     steps:
echo     - uses: actions/checkout@v4
echo     - uses: actions/setup-java@v4
echo       with:
echo         java-version: '17'
echo         distribution: 'temurin'
echo     - run: chmod +x gradlew || true
echo     - run: ./gradlew assembleDebug --stacktrace
echo     - uses: actions/upload-artifact@v4
echo       with:
echo         name: RestoPOS-Debug-APK
echo         path: app/build/outputs/apk/debug/app-debug.apk
) > RestoPOS\.github\workflows\android-build.yml

:: 2. Root build.gradle.kts
(
echo plugins {
echo     id("com.android.application") version "8.2.0" apply false
echo     id("org.jetbrains.kotlin.android") version "1.9.22" apply false
echo ^}
) > RestoPOS\build.gradle.kts

:: 3. Settings.gradle.kts
(
echo pluginManagement { repositories { google(); mavenCentral(); gradlePluginPortal() } }
echo dependencyResolutionManagement { repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS); repositories { google(); mavenCentral() } }
echo rootProject.name = "RestoPOS"
echo include(":app")
) > RestoPOS\settings.gradle.kts

:: 4. App build.gradle.kts
(
echo plugins { id("com.android.application"); id("org.jetbrains.kotlin.android") }
echo android {
echo     namespace = "com.example.restopos"
echo     compileSdk = 34
echo     defaultConfig { applicationId = "com.example.restopos"; minSdk = 24; targetSdk = 34; versionCode = 1; versionName = "1.0" }
echo     buildTypes { release { isMinifyEnabled = false } }
echo     compileOptions { sourceCompatibility = JavaVersion.VERSION_17; targetCompatibility = JavaVersion.VERSION_17 }
echo     kotlinOptions { jvmTarget = "17" }
echo     buildFeatures { compose = true }
echo     composeOptions { kotlinCompilerExtensionVersion = "1.5.8" }
echo ^}
echo dependencies {
echo     implementation("androidx.core:core-ktx:1.12.0")
echo     implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.7.0")
echo     implementation("androidx.activity:activity-compose:1.8.2")
echo     implementation(platform("androidx.compose:compose-bom:2024.02.00"))
echo     implementation("androidx.compose.ui:ui")
echo     implementation("androidx.compose.ui:ui-graphics")
echo     implementation("androidx.compose.ui:ui-tooling-preview")
echo     implementation("androidx.compose.material3:material3")
echo     implementation("io.coil-kt:coil-compose:2.5.0")
echo ^}
) > RestoPOS\app\build.gradle.kts

:: 5. Manifest
(
echo ^<manifest xmlns:android="http://schemas.android.com/apk/res/android"^>
echo     ^<uses-permission android:name="android.permission.INTERNET" /^>
echo     ^<application android:allowBackup="true" android:label="Lotus POS" android:supportsRtl="true" android:theme="@android:style/Theme.Material.Light.NoTitleBar"^>
echo         ^<activity android:name=".MainActivity" android:exported="true"^>
echo             ^<intent-filter^>
echo                 ^<action android:name="android.intent.action.MAIN" /^>
echo                 ^<category android:name="android.intent.category.LAUNCHER" /^>
echo             ^/intent-filter^>
echo         ^/activity^>
echo     ^/application^>
echo ^/manifest^>
) > RestoPOS\app\src\main\AndroidManifest.xml

:: 6. MainActivity
(
echo package com.example.restopos
echo import android.os.Bundle
echo import androidx.activity.ComponentActivity
echo import androidx.activity.compose.setContent
echo import androidx.compose.foundation.layout.fillMaxSize
echo import androidx.compose.material3.MaterialTheme
echo import androidx.compose.material3.Surface
echo import androidx.compose.ui.Modifier
echo import com.example.restopos.ui.POSMenuScreen
echo class MainActivity : ComponentActivity^(^) {
echo     override fun onCreate^(savedInstanceState: Bundle?^) {
echo         super.onCreate^(savedInstanceState^)
echo         setContent { MaterialTheme { Surface^(modifier = Modifier.fillMaxSize^(^), color = MaterialTheme.colorScheme.background^) { POSMenuScreen^(^) } } }
echo     }
echo ^}
) > RestoPOS\app\src\main\java\com\example\restopos\MainActivity.kt

:: 7. POSMenuScreen
(
echo package com.example.restopos.ui
echo import android.widget.Toast
echo import androidx.compose.foundation.BorderStroke
echo import androidx.compose.foundation.background
echo import androidx.compose.foundation.border
echo import androidx.compose.foundation.clickable
echo import androidx.compose.foundation.layout.*
echo import androidx.compose.foundation.lazy.LazyColumn
echo import androidx.compose.foundation.lazy.LazyRow
echo import androidx.compose.foundation.lazy.items
echo import androidx.compose.foundation.shape.CircleShape
echo import androidx.compose.foundation.shape.RoundedCornerShape
echo import androidx.compose.material3.*
echo import androidx.compose.runtime.*
echo import androidx.compose.ui.Alignment
echo import androidx.compose.ui.Modifier
echo import androidx.compose.ui.draw.clip
echo import androidx.compose.ui.graphics.Color
echo import androidx.compose.ui.platform.LocalContext
echo import androidx.compose.ui.text.font.FontWeight
echo import androidx.compose.ui.text.style.TextDecoration
echo import androidx.compose.ui.unit.dp
echo import androidx.compose.ui.unit.sp
echo data class Product^(val id: String, val name: String, val description: String, val price: Double, val oldPrice: Double? = null, val badge: String? = null, val isAvailable: Boolean = true, val crossSellProduct: String? = null^)
echo data class Story^(val id: String, val title: String, val hasUnseen: Boolean = true^)
echo @OptIn^(ExperimentalMaterial3Api::class^)
echo @Composable
echo fun POSMenuScreen^(^) {
echo     val context = LocalContext.current
echo     val dynamicKdvRate by remember { mutableStateOf^(10^) }
echo     val isCallWaiterActive by remember { mutableStateOf^(true^) }
echo     val stories = listOf^(Story^("1", "Günün Tatlısı"^), Story^("2", "Kampanyalar"^), Story^("3", "Kahveler"^), Story^("4", "Biz Kimiz?"^)^)
echo     val products = listOf^(
echo         Product^("1", "Lotus Atelier Special", "Belçika çikolatası", 180.0, badge = "En Çok Satan", crossSellProduct = "Yanına Espresso çok yakışır!"^),
echo         Product^("2", "San Sebastian", "Akışkan kıvamlı", 210.0, oldPrice = 240.0, badge = "%12 İndirim"^)
echo     ^)
echo     Scaffold^(topBar = { TopAppBar^(title = { Text^("Lotus Atelier Menu", fontWeight = FontWeight.Bold^) }^) }^) { p ->
echo         LazyColumn^(modifier = Modifier.fillMaxSize^(^).padding^(p^).padding^(16.dp^)^) {
echo             item {
echo                 Text^("Öne Çıkanlar", fontWeight = FontWeight.Bold, fontSize = 16.sp^)
echo                 Spacer^(modifier = Modifier.height^(8.dp^)^)
echo                 LazyRow^(horizontalArrangement = Arrangement.spacedBy^(12.dp^)^) {
echo                     items^(stories^) { s ->
echo                         Column^(horizontalAlignment = Alignment.CenterHorizontally^) {
echo                             Box^(modifier = Modifier.size^(64.dp^).border^(BorderStroke^(2.dp, Color^(0xFFE91E63^)^), CircleShape^).padding^(4.dp^).clip^(CircleShape^).background^(Color.LightGray^), contentAlignment = Alignment.Center^) {
echo                                 Text^(s.title.take^(2^), fontWeight = FontWeight.Bold^)
echo                             }
echo                             Text^(s.title, fontSize = 11.sp^)
echo                         }
echo                     }
echo                 }
echo                 Divider^(modifier = Modifier.padding^(vertical = 16.dp^)^)
echo             }
echo             items^(products^) { prod ->
echo                 Card^(modifier = Modifier.fillMaxWidth^(^), shape = RoundedCornerShape^(12.dp^)^) {
echo                     Column^(modifier = Modifier.padding^(16.dp^)^) {
echo                         Text^(prod.name, fontWeight = FontWeight.Bold, fontSize = 16.sp^)
echo                         Text^(prod.description, fontSize = 13.sp, color = Color.Gray^)
echo                         Spacer^(modifier = Modifier.height^(8.dp^)^)
echo                         Text("${prod.price} TL", fontWeight = FontWeight.ExtraBold, color = Color^(0xFF2E7D32^))
echo                         prod.crossSellProduct?.let { Text("💡 $it", fontSize = 11.sp, color = Color^(0xFF1565C0^)^) }
echo                     }
echo                 }
echo                 Spacer^(modifier = Modifier.height^(12.dp^)^)
echo             }
echo         }
echo     }
echo }
) > RestoPOS\app\src\main\java\com\example\restopos\ui\POSMenuScreen.kt

