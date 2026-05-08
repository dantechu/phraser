# Home Screen Widget Implementation Guide

This guide explains how to implement home screen widgets for the Phraser app that display quotes on both iOS and Android.

## Overview

The Phraser app widgets will display:
- Daily inspirational quotes from the current phraser list
- Quote category
- Beautiful, themed design
- Tap to refresh with new quote
- Tap to open app

## Step 1: Add Dependencies

Add the `home_widget` package to `pubspec.yaml`:

```yaml
dependencies:
  home_widget: ^0.6.0  # Add this line
```

Then run:
```bash
flutter pub get
```

## Step 2: iOS Widget Implementation

### 2.1 Create Widget Extension in Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. File → New → Target → Widget Extension
3. Name: `PhraserWidget`
4. Language: Swift
5. Uncheck "Include Configuration Intent"

### 2.2 Create Widget Code (Swift)

Create `ios/PhraserWidget/PhraserWidget.swift`:

```swift
import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> QuoteEntry {
        QuoteEntry(date: Date(), quote: "Loading...", category: "Phraser")
    }

    func getSnapshot(in context: Context, completion: @escaping (QuoteEntry) -> ()) {
        let entry = QuoteEntry(
            date: Date(),
            quote: UserDefaults(suiteName: "group.com.yourcompany.phraser")?.string(forKey: "quote_text") ?? "Open Phraser for inspiration",
            category: UserDefaults(suiteName: "group.com.yourcompany.phraser")?.string(forKey: "quote_category") ?? "Daily Quote"
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let entry = QuoteEntry(
            date: currentDate,
            quote: UserDefaults(suiteName: "group.com.yourcompany.phraser")?.string(forKey: "quote_text") ?? "Open Phraser for inspiration",
            category: UserDefaults(suiteName: "group.com.yourcompany.phraser")?.string(forKey: "quote_category") ?? "Daily Quote"
        )

        // Refresh every hour
        let nextUpdateDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        completion(timeline)
    }
}

struct QuoteEntry: TimelineEntry {
    let date: Date
    let quote: String
    let category: String
}

struct PhraserWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.4, green: 0.6, blue: 0.9), Color(red: 0.6, green: 0.4, blue: 0.9)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 12) {
                // Quote icon
                Image(systemName: "quote.bubble.fill")
                    .font(.system(size: family == .systemSmall ? 24 : 32))
                    .foregroundColor(.white.opacity(0.9))

                // Quote text
                Text(entry.quote)
                    .font(.system(size: family == .systemSmall ? 14 : 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(family == .systemSmall ? 4 : 6)
                    .padding(.horizontal)

                Spacer()

                // Category badge
                Text(entry.category.uppercased())
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                    )
            }
            .padding()
        }
    }
}

@main
struct PhraserWidget: Widget {
    let kind: String = "PhraserWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PhraserWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Daily Quote")
        .description("Get inspired with daily quotes from Phraser")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
```

### 2.3 Configure App Group

1. In Xcode, select Runner target
2. Signing & Capabilities → + Capability → App Groups
3. Add group: `group.com.yourcompany.phraser`
4. Repeat for PhraserWidget target

### 2.4 Update Info.plist

Add to `ios/Runner/Info.plist`:

```xml
<key>AppGroupContainerIdentifier</key>
<string>group.com.yourcompany.phraser</string>
```

## Step 3: Android Widget Implementation

### 3.1 Create Widget Layout

Create `android/app/src/main/res/layout/phraser_widget.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@drawable/widget_background"
    android:padding="16dp">

    <ImageView
        android:id="@+id/widget_icon"
        android:layout_width="32dp"
        android:layout_height="32dp"
        android:layout_centerHorizontal="true"
        android:src="@drawable/ic_quote"
        android:tint="#FFFFFF"
        android:alpha="0.9" />

    <TextView
        android:id="@+id/widget_quote"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_below="@id/widget_icon"
        android:layout_marginTop="16dp"
        android:text="Open Phraser for inspiration"
        android:textSize="16sp"
        android:textColor="#FFFFFF"
        android:textAlignment="center"
        android:fontFamily="sans-serif-medium"
        android:lineSpacingExtra="4dp"
        android:maxLines="6"
        android:ellipsize="end" />

    <TextView
        android:id="@+id/widget_category"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_alignParentBottom="true"
        android:layout_centerHorizontal="true"
        android:text="DAILY QUOTE"
        android:textSize="10sp"
        android:textColor="#FFFFFF"
        android:alpha="0.8"
        android:fontFamily="sans-serif-medium"
        android:letterSpacing="0.1"
        android:paddingStart="12dp"
        android:paddingEnd="12dp"
        android:paddingTop="4dp"
        android:paddingBottom="4dp"
        android:background="@drawable/category_badge" />

</RelativeLayout>
```

### 3.2 Create Widget Background

Create `android/app/src/main/res/drawable/widget_background.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <gradient
        android:angle="135"
        android:startColor="#6699CC"
        android:centerColor="#9966CC"
        android:endColor="#CC6699"
        android:type="linear" />
    <corners android:radius="16dp" />
</shape>
```

### 3.3 Create Category Badge

Create `android/app/src/main/res/drawable/category_badge.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="#33FFFFFF" />
    <corners android:radius="12dp" />
</shape>
```

### 3.4 Create Quote Icon

Create `android/app/src/main/res/drawable/ic_quote.xml`:

```xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="#FFFFFF"
        android:pathData="M6,17h3l2,-4V7H5v6h3L6,17z M18,17h3l2,-4V7h-6v6h3L18,17z"/>
</vector>
```

### 3.5 Create Widget Provider

Create `android/app/src/main/kotlin/.../PhraserWidgetProvider.kt`:

```kotlin
package com.yourcompany.phraser

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
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
                val quoteText = prefs.getString("quote_text", "Open Phraser for inspiration")
                val category = prefs.getString("quote_category", "Daily Quote")

                setTextViewText(R.id.widget_quote, quoteText)
                setTextViewText(R.id.widget_category, category?.uppercase())

                // Set click listener to open app
                val pendingIntent = HomeWidgetPlugin.getPendingIntent(
                    context,
                    "android.intent.action.VIEW",
                    "phraser://open"
                )
                setOnClickPendingIntent(R.id.widget_quote, pendingIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
```

### 3.6 Register Widget in AndroidManifest.xml

Add to `android/app/src/main/AndroidManifest.xml` inside `<application>`:

```xml
<receiver
    android:name=".PhraserWidgetProvider"
    android:exported="true">
    <intent-filter>
        <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
    </intent-filter>
    <meta-data
        android:name="android.appwidget.provider"
        android:resource="@xml/phraser_widget_info" />
</receiver>
```

### 3.7 Create Widget Info

Create `android/app/src/main/res/xml/phraser_widget_info.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<appwidget-provider xmlns:android="http://schemas.android.com/apk/res/android"
    android:description="@string/widget_description"
    android:initialLayout="@layout/phraser_widget"
    android:minWidth="180dp"
    android:minHeight="110dp"
    android:previewImage="@drawable/widget_preview"
    android:resizeMode="horizontal|vertical"
    android:targetCellWidth="3"
    android:targetCellHeight="2"
    android:updatePeriodMillis="3600000"
    android:widgetCategory="home_screen" />
```

### 3.8 Add Strings

Add to `android/app/src/main/res/values/strings.xml`:

```xml
<string name="widget_description">Display daily inspirational quotes</string>
```

## Step 4: Flutter Integration

### 4.1 Initialize Widget Service

In `main.dart`:

```dart
import 'package:phraser/services/widget_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize widget service
  await WidgetService().initialize();

  runApp(MyApp());
}
```

### 4.2 Update Widget When Quote Changes

In `phraser_view.dart`, update widget when user swipes to a new quote:

```dart
onPageChanged: (int index, _) async {
  Preferences.instance.currentPhraserPosition = index;

  if (DataRepository().currentPhrasersList.isNotEmpty &&
      index < DataRepository().currentPhrasersList.length) {
    final quote = DataRepository().currentPhrasersList[index];

    // Update home screen widget
    await WidgetService().updateWidgetWithQuote(quote);

    _phraserViewModel.isFavorites(quote);
  }
},
```

### 4.3 Update Widget on App Launch

In `splash_screen.dart`:

```dart
@override
void initState() {
  super.initState();
  _initializeApp();
}

Future<void> _initializeApp() async {
  // ... existing initialization code ...

  // Update widget with current quote
  await WidgetService().updateWidget();
}
```

### 4.4 Add Widget Button to Settings

In `settings_screen.dart`, add an option to add widget:

```dart
ListTile(
  leading: Icon(Icons.widgets),
  title: Text('Add Home Screen Widget'),
  subtitle: Text('Display quotes on your home screen'),
  onTap: () async {
    final added = await WidgetService().requestPinWidget();
    if (added) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Widget added to home screen!')),
      );
    }
  },
),
```

## Step 5: Testing

### iOS Testing
1. Run the app on a physical iOS device or simulator
2. Long-press on home screen → tap '+' icon
3. Search for "Phraser"
4. Add the widget
5. Verify quote displays correctly

### Android Testing
1. Run the app on an Android device or emulator
2. Long-press on home screen → Widgets
3. Find and add "Phraser Widget"
4. Verify quote displays correctly

## Features

✅ Beautiful gradient background
✅ Displays current quote from phraser list
✅ Shows quote category
✅ Auto-updates every hour
✅ Tap to open app
✅ Supports multiple widget sizes (iOS)
✅ Responsive design

## Customization

You can customize the widget appearance by:
- Modifying colors in `widget_background.xml` (Android) or SwiftUI code (iOS)
- Changing font sizes and styles
- Adding more widget sizes
- Implementing different themes
- Adding refresh button

## Troubleshooting

**Widget not updating:**
- Check app group configuration (iOS)
- Verify SharedPreferences are being saved
- Check widget update interval

**Widget shows default text:**
- Ensure WidgetService().updateWidget() is being called
- Check that quotes are loaded in DataRepository

**Build errors:**
- Run `flutter clean && flutter pub get`
- Regenerate platform files
- Verify all XML/Swift files are correct

## Next Steps

Consider implementing:
- Multiple widget themes
- User-selectable update intervals
- Widget configuration screen
- Daily quote notifications
- Widget interactions (next/previous quote buttons)
