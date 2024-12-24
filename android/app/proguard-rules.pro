# Preserve class names for Firebase libraries
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Preserve models annotated with @Keep
-keepattributes *Annotation*
-keep class * {
    @com.google.firebase.database.IgnoreExtraProperties *;
}

# General rule to prevent obfuscation for the main application
-keep public class * extends android.app.Application
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.app.Activity
-keep public class * extends android.content.Service

# Add Razorpay-related rules
-keep class com.razorpay.** { *; }
-keepattributes Exceptions

# Uncomment the following line if using Kotlin reflection
#-keepclassmembers class * { @kotlin.Metadata *; }
