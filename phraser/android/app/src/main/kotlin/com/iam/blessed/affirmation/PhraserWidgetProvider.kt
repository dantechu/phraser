package com.iam.blessed.affirmation

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.os.Build
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class PhraserWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        appWidgetIds.forEach { widgetId ->
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
    }
}
