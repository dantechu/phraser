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

class PhraserWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val ACTION_AUTO_UPDATE = "com.iam.blessed.affirmation.AUTO_UPDATE"
        private const val UPDATE_INTERVAL = 5 * 60 * 1000L // 5 minutes in milliseconds
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

        if (intent.action == ACTION_AUTO_UPDATE) {
            // Get all widget IDs and update them
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val widgetIds = appWidgetManager.getAppWidgetIds(
                android.content.ComponentName(context, PhraserWidgetProvider::class.java)
            )

            // Move to next quote
            moveToNextQuote(context)

            // Update all widgets
            widgetIds.forEach { widgetId ->
                updateWidget(context, appWidgetManager, widgetId)
            }

            // Schedule next update
            scheduleNextUpdate(context)
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

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.ELAPSED_REALTIME_WAKEUP,
                triggerTime,
                pendingIntent
            )
        } else {
            alarmManager.setExact(
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

    private fun moveToNextQuote(context: Context) {
        // Get quote list from shared preferences (stored by home_widget plugin)
        val prefs = HomeWidgetPlugin.getData(context)

        // Get current quote index
        val currentIndex = prefs.getInt("current_quote_index", 0)

        // Get total quotes count
        val totalQuotes = prefs.getInt("total_quotes", 0)

        if (totalQuotes > 0) {
            // Calculate next index (wrap around if at the end)
            val nextIndex = (currentIndex + 1) % totalQuotes

            // Get the next quote and category from pre-stored data
            val nextQuote = prefs.getString("quote_$nextIndex", null)
            val nextCategory = prefs.getString("category_$nextIndex", null)

            if (nextQuote != null && nextCategory != null) {
                // Update current index
                prefs.edit().putInt("current_quote_index", nextIndex).apply()

                // Update the displayed quote
                prefs.edit().putString("quote_text", nextQuote).apply()
                prefs.edit().putString("quote_category", nextCategory).apply()
            }
        }
    }
}
