# Mengabaikan peringatan dari library ucrop dan okhttp
-dontwarn com.yalantis.ucrop**
-dontwarn okhttp3**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }