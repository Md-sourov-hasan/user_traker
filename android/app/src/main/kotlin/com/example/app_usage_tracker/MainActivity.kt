package com.example.app_usage_tracker

import android.app.usage.UsageStatsManager
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private val CHANNEL = "app.usage"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->

                if (call.method == "getUsageStats") {
                    result.success(getUsageStats())
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun getUsageStats(): HashMap<String, Long> {

        val usageStatsManager =
            getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

        val endTime = System.currentTimeMillis()
        val startTime = endTime - (1000 * 60 * 60 * 24)

        val stats =
            usageStatsManager.queryUsageStats(
                UsageStatsManager.INTERVAL_DAILY,
                startTime,
                endTime
            )

        val usageMap = HashMap<String, Long>()

        for (usage in stats) {
            usageMap[usage.packageName] = usage.totalTimeInForeground
        }

        return usageMap
    }
}
