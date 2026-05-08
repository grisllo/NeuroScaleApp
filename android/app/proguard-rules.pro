# Reglas Proguard / R8 para release builds.
# Se aplican junto a proguard-android-optimize.txt (defaults Android).

# --- Flutter framework ---
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**

# --- Sentry Android SDK ---
# Sentry usa reflection para integrations y breadcrumbs nativos.
-keep class io.sentry.** { *; }
-dontwarn io.sentry.**

# --- Kotlin metadata (requerido por algunos plugins) ---
-keep class kotlin.Metadata { *; }
-keepclassmembers class kotlin.Metadata { *; }

# --- Annotations comunes ---
-dontwarn javax.annotation.**
-dontwarn org.jetbrains.annotations.**
