# Phraser Home Screen Widget Setup Guide

## ✅ Implementation Status: COMPLETE

All code files have been created and integrated. This guide covers the final Xcode/Android Studio configuration steps.

---

## 📱 What's Been Implemented

### Flutter/Dart (✅ Complete)
- ✅ **widget_service.dart** - Core widget management service
- ✅ **main.dart** - WidgetService initialized on app startup
- ✅ **phraser_view.dart** - Widget syncs when user swipes through quotes
- ✅ **pubspec.yaml** - home_widget package added

### iOS (✅ Complete - Needs Xcode Config)
- ✅ **PhraserWidget.swift** - SwiftUI widget with gradient background
- ✅ **Info.plist** - Widget extension configuration
- ✅ **PhraserWidget.entitlements** - App Groups for data sharing
- ✅ **Runner.entitlements** - App Groups enabled in main app

### Android (✅ Complete - Ready to Build)
- ✅ **PhraserWidgetProvider.kt** - Widget provider implementation
- ✅ **phraser_widget.xml** - Widget layout
- ✅ **phraser_widget_info.xml** - Widget metadata
- ✅ **widget_background.xml** - Gradient drawable
- ✅ **ic_quote.xml** - Quote icon
- ✅ **AndroidManifest.xml** - Widget registered

---

## 🎯 How It Works

1. **Quote Sync**: When you swipe through quotes in the app, the home screen widget automatically updates
2. **Data Sharing**:
   - **iOS**: Uses App Groups (`group.phraser.widget`) to share data
   - **Android**: Uses SharedPreferences via home_widget plugin
3. **Auto Refresh**: Widgets refresh hourly automatically
4. **Beautiful UI**: Gradient background with quote text and category badge

---

## 🛠 Xcode Setup (iOS Widget) - REQUIRED

### Step 1: Open Xcode
```bash
cd ios
open Runner.xcworkspace
```

### Step 2: Add Widget Extension Target

1. In Xcode, select the **Runner** project in the left sidebar
2. Click the **+** button at the bottom of the targets list
3. Select **Widget Extension** template
4. Configure:
   - **Product Name**: `PhraserWidget`
   - **Team**: Select your Apple Developer team
   - **Bundle Identifier**: `com.dantechustudios.phraser.PhraserWidget`
   - Uncheck "Include Configuration Intent"
5. Click **Finish**
6. When prompted "Activate PhraserWidget scheme?", click **Activate**

### Step 3: Replace Generated Files

The widget extension will generate template files. Replace them with our files:

1. Delete the auto-generated files in `PhraserWidget/` folder (keep only the files we created)
2. In Xcode's **PhraserWidget** folder, verify these files exist:
   - ✅ PhraserWidget.swift
   - ✅ Info.plist
   - ✅ PhraserWidget.entitlements

### Step 4: Configure App Groups

#### For Runner Target:
1. Select **Runner** target
2. Go to **Signing & Capabilities** tab
3. Verify **App Groups** capability exists
4. Verify `group.phraser.widget` is checked

#### For PhraserWidget Target:
1. Select **PhraserWidget** target
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability**
4. Add **App Groups**
5. Click **+** to add a new App Group
6. Enter: `group.phraser.widget`
7. Enable the checkbox

### Step 5: Configure Entitlements

#### PhraserWidget.entitlements
The file should already contain:
```xml
<key>com.apple.security.application-groups</key>
<array>
    <string>group.phraser.widget</string>
</array>
```

#### Runner.entitlements
Already configured with:
```xml
<key>com.apple.security.application-groups</key>
<array>
    <string>group.phraser.widget</string>
</array>
```

### Step 6: Build Settings

For **PhraserWidget** target:
1. Go to **Build Settings**
2. Search for "Deployment Target"
3. Set **iOS Deployment Target** to **14.0** or higher (WidgetKit requirement)

### Step 7: Build and Run

1. Select **Runner** scheme (not PhraserWidget)
2. Build the project: **Cmd + B**
3. Run on device: **Cmd + R**
4. If successful, the app will launch

---

## 📱 Adding Widget to Home Screen

### iOS:
1. Long-press on home screen
2. Tap the **+** button (top-left)
3. Search for **"Phraser"**
4. Select the widget size (Small or Medium)
5. Tap **Add Widget**
6. Done! Widget should display current quote

### Android:
1. Long-press on home screen
2. Tap **Widgets**
3. Find **Phraser Widget**
4. Drag to home screen
5. Done! Widget should display current quote

---

## 🔧 Troubleshooting

### iOS Widget Not Showing
**Problem**: Widget doesn't appear in widget picker
- **Solution**: Clean build folder (Cmd + Shift + K), then rebuild
- **Check**: Ensure PhraserWidget target is included in build scheme

**Problem**: Widget shows "Open Phraser..."
- **Solution**: Open the app, swipe through quotes to initialize data
- **Check**: Verify App Groups match exactly: `group.phraser.widget`

**Problem**: Widget not updating
- **Solution**:
  1. Check App Groups are enabled for BOTH Runner and PhraserWidget
  2. Verify group ID is `group.phraser.widget` (no typos)
  3. Remove and re-add widget to home screen

### Android Widget Not Showing
**Problem**: Widget doesn't appear in widget list
- **Solution**:
  1. Run `flutter clean`
  2. Rebuild: `flutter build apk --debug`
  3. Reinstall the app

**Problem**: Widget shows default text
- **Solution**: Open the app and swipe to a quote to trigger update

### General Issues
**Problem**: Build errors in Xcode
- **Solution**:
  1. Ensure iOS deployment target is 14.0+
  2. Clean derived data: `Product > Clean Build Folder`
  3. Restart Xcode

**Problem**: App Groups permission denied
- **Solution**: You need an active Apple Developer account to use App Groups

---

## 🎨 Widget Features

### Supported Sizes
- **iOS**: Small (2x2), Medium (4x2)
- **Android**: Flexible sizing (minimum 180x110dp)

### Design
- Beautiful gradient background (blue → purple → pink)
- Quote icon at top
- Centered quote text with line spacing
- Category badge at bottom
- Tap widget to open app

### Auto-Update
- Updates when you swipe through quotes in the app
- Refreshes hourly automatically
- Syncs across app restart

---

## 📝 Implementation Details

### App Group ID
- **ID**: `group.phraser.widget`
- **Purpose**: Share quote data between main app and widget
- **Platforms**: iOS only (Android uses SharedPreferences)

### Widget IDs
- **iOS**: `PhraserWidget`
- **Android**: `PhraserWidgetProvider`

### Data Storage Keys
```dart
'quote_text'      // The quote text
'quote_category'  // Category name
'quote_id'        // Unique quote ID
'has_data'        // Boolean flag
'last_updated'    // ISO timestamp
```

---

## ✅ Testing Checklist

- [ ] Xcode builds without errors
- [ ] App runs on device/simulator
- [ ] Widget appears in widget picker
- [ ] Widget displays on home screen
- [ ] Widget shows current quote
- [ ] Widget updates when swiping quotes in app
- [ ] Tapping widget opens app
- [ ] Widget persists after app restart
- [ ] Widget refreshes hourly

---

## 🚀 Next Steps

1. **Open Xcode**: `cd ios && open Runner.xcworkspace`
2. **Configure App Groups**: Follow Step 4 above
3. **Build**: Cmd + B
4. **Test**: Run on device, add widget to home screen
5. **Deploy**: Build release version when ready

---

## 📞 Support

If you encounter issues:
1. Check all file paths match this guide
2. Verify App Group ID is exactly `group.phraser.widget`
3. Ensure iOS deployment target is 14.0+
4. Clean and rebuild project
5. Check Xcode console for error messages

The implementation is **complete** - only Xcode configuration remains!
