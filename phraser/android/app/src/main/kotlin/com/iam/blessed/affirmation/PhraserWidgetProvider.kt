package com.iam.blessed.affirmation

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.SystemClock
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class PhraserWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val ACTION_AUTO_UPDATE = "com.iam.blessed.affirmation.AUTO_UPDATE"
        //private const val UPDATE_INTERVAL = 5 * 60 * 1000L // 5 minutes in milliseconds
        private const val UPDATE_INTERVAL = 30 * 1000L // 30 seconds for testing

    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        appWidgetIds.forEach { widgetId ->
            updateWidget(context, appWidgetManager, widgetId)
        }

        // Schedule periodic updates
        scheduleNextUpdate(context)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)

        android.util.Log.d("PhraserWidget", "onReceive called with action: ${intent.action}")

        if (intent.action == ACTION_AUTO_UPDATE) {
            android.util.Log.d("PhraserWidget", "AUTO_UPDATE triggered - updating widget")

            // Use coroutine to handle async database operations
            CoroutineScope(Dispatchers.Main).launch {
                try {
                    // Move to next quote (reads from database)
                    moveToNextQuote(context)

                    // Get all widget IDs and update them
                    val appWidgetManager = AppWidgetManager.getInstance(context)
                    val widgetIds = appWidgetManager.getAppWidgetIds(
                        android.content.ComponentName(context, PhraserWidgetProvider::class.java)
                    )

                    android.util.Log.d("PhraserWidget", "Found ${widgetIds.size} widgets to update")

                    // Update all widgets
                    widgetIds.forEach { widgetId ->
                        updateWidget(context, appWidgetManager, widgetId)
                    }

                    // Schedule next update
                    scheduleNextUpdate(context)
                } catch (e: Exception) {
                    android.util.Log.e("PhraserWidget", "Error in auto-update: ${e.message}", e)
                }
            }
        }
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        // First widget added, start scheduling updates
        scheduleNextUpdate(context)
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        // Last widget removed, cancel scheduled updates
        cancelUpdates(context)
    }

    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        widgetId: Int
    ) {
        val views = RemoteViews(context.packageName, R.layout.phraser_widget).apply {
            val prefs = HomeWidgetPlugin.getData(context)
            val quoteText = prefs.getString("quote_text", "Open Phraser for daily inspiration")
            val category = prefs.getString("quote_category", "Daily Quote")

            setTextViewText(R.id.widget_quote, quoteText)
            setTextViewText(R.id.widget_category, category?.uppercase())

            // Set click listener to open app
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }

            val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }

            val pendingIntent = PendingIntent.getActivity(context, 0, intent, flags)
            setOnClickPendingIntent(R.id.widget_quote, pendingIntent)
        }

        appWidgetManager.updateAppWidget(widgetId, views)
    }

    private fun scheduleNextUpdate(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, PhraserWidgetProvider::class.java).apply {
            action = ACTION_AUTO_UPDATE
        }

        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }

        val pendingIntent = PendingIntent.getBroadcast(context, 0, intent, flags)

        // Cancel any existing alarm
        alarmManager.cancel(pendingIntent)

        // Schedule new alarm
        val triggerTime = SystemClock.elapsedRealtime() + UPDATE_INTERVAL

        android.util.Log.d("PhraserWidget", "Scheduling next update in ${UPDATE_INTERVAL / 1000} seconds")

        try {
            // Check if we can schedule exact alarms (Android 12+)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                // Android 12+ requires checking for exact alarm permission
                if (alarmManager.canScheduleExactAlarms()) {
                    alarmManager.setExactAndAllowWhileIdle(
                        AlarmManager.ELAPSED_REALTIME_WAKEUP,
                        triggerTime,
                        pendingIntent
                    )
                    android.util.Log.d("PhraserWidget", "Scheduled exact alarm")
                } else {
                    // Fallback to inexact alarm if permission not granted
                    alarmManager.set(
                        AlarmManager.ELAPSED_REALTIME_WAKEUP,
                        triggerTime,
                        pendingIntent
                    )
                    android.util.Log.d("PhraserWidget", "Scheduled inexact alarm (no exact alarm permission)")
                }
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.ELAPSED_REALTIME_WAKEUP,
                    triggerTime,
                    pendingIntent
                )
                android.util.Log.d("PhraserWidget", "Scheduled exact alarm (API < 31)")
            } else {
                alarmManager.setExact(
                    AlarmManager.ELAPSED_REALTIME_WAKEUP,
                    triggerTime,
                    pendingIntent
                )
                android.util.Log.d("PhraserWidget", "Scheduled exact alarm (API < 23)")
            }
        } catch (e: SecurityException) {
            // Permission not granted, use inexact alarm as fallback
            android.util.Log.e("PhraserWidget", "Cannot schedule exact alarm, using inexact: ${e.message}")
            alarmManager.set(
                AlarmManager.ELAPSED_REALTIME_WAKEUP,
                triggerTime,
                pendingIntent
            )
        }
    }

    private fun cancelUpdates(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, PhraserWidgetProvider::class.java).apply {
            action = ACTION_AUTO_UPDATE
        }

        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }

        val pendingIntent = PendingIntent.getBroadcast(context, 0, intent, flags)
        alarmManager.cancel(pendingIntent)
    }

    private suspend fun moveToNextQuote(context: Context) = withContext(Dispatchers.IO) {
        android.util.Log.d("PhraserWidget", "moveToNextQuote called")

        try {
            // Get widget data from HomeWidget plugin
            val widgetPrefs = HomeWidgetPlugin.getData(context)

            // Get current index and total quotes
            val currentIndex = widgetPrefs.getInt("current_quote_index", 0)
            val totalQuotes = widgetPrefs.getInt("total_quotes", 0)

            android.util.Log.d("PhraserWidget", "Current index: $currentIndex, Total quotes: $totalQuotes")

            if (totalQuotes > 0) {
                // Calculate next index (wrap around to 0 if at end)
                val nextIndex = (currentIndex + 1) % totalQuotes

                // Get the next quote and category
                val nextQuote = widgetPrefs.getString("quote_$nextIndex", null)
                val nextCategory = widgetPrefs.getString("category_$nextIndex", null)

                android.util.Log.d("PhraserWidget", "Moving to index $nextIndex, Quote exists: ${nextQuote != null}")

                if (nextQuote != null && nextCategory != null) {
                    // Update the widget data with next quote
                    val editor = widgetPrefs.edit()
                    editor.putInt("current_quote_index", nextIndex)
                    editor.putString("quote_text", nextQuote)
                    editor.putString("quote_category", nextCategory)
                    editor.apply()

                    // Also update Flutter's position to keep in sync
                    val flutterPrefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                    flutterPrefs.edit().putInt("flutter.phraserPosition", nextIndex).apply()

                    android.util.Log.d("PhraserWidget", "✅ Updated to quote $nextIndex: ${nextQuote.take(50)}...")
                } else {
                    android.util.Log.e("PhraserWidget", "❌ Quote at index $nextIndex not found")
                }
            } else {
                android.util.Log.e("PhraserWidget", "❌ No quotes stored. Total quotes: $totalQuotes")
            }

        } catch (e: Exception) {
            android.util.Log.e("PhraserWidget", "❌ Error in moveToNextQuote: ${e.message}", e)
        }
    }
}
