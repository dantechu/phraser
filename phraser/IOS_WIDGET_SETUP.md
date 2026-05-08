# iOS Widget Setup - Step by Step

Follow these exact steps to get the iOS widget working:

## Step 1: Open Xcode

```bash
cd ios
open Runner.xcworkspace
```

## Step 2: Create Widget Extension (If Not Already Created)

1. In Xcode menu: **File → New → Target**
2. Search for "Widget Extension"
3. Click **Widget Extension**, then **Next**
4. Fill in:
   - **Product Name:** `PhraserWidget`
   - **Team:** Your development team
   - **Organization Identifier:** Same as your app
   - **Language:** Swift
   - **Project:** Runner
   - **Embed in Application:** Runner
   - **Include Configuration Intent:** ❌ UNCHECK THIS
5. Click **Finish**
6. When asked "Activate PhraserWidget scheme?", click **Activate**

## Step 3: Configure App Groups

### For Main App (Runner):
1. Select **Runner** target (not Runner project)
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability**
4. Add **App Groups**
5. Click **+** to add a group
6. Enter: `group.phraser.widget`
7. Make sure it's **checked** ✅

### For Widget Extension (PhraserWidget):
1. Select **PhraserWidget** target
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability**
4. Add **App Groups**
5. Click **+** to add a group
6. Enter: `group.phraser.widget` (SAME as main app)
7. Make sure it's **checked** ✅

## Step 4: Replace Widget Code

1. In Xcode Project Navigator, find **PhraserWidget** folder
2. Open `PhraserWidget.swift`
3. Replace ALL content with the code from: `ios/PhraserWidget/PhraserWidget.swift`

The widget code uses `group.phraser.widget` to share data between app and widget.

## Step 5: Update Runner's Entitlements

1. In Xcode, select **Runner** target
2. Find or create file: `Runner/Runner.entitlements`
3. Add this content:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.security.application-groups</key>
	<array>
		<string>group.phraser.widget</string>
	</array>
</dict>
</plist>
```

## Step 6: Update Widget Service to Use Correct Group

The widget service needs to set the App Group. Update the `initialize()` method in `widget_service.dart`:

```dart
Future<void> initialize() async {
  try {
    // Set the App Group ID for iOS
    await HomeWidget.setAppGroupId('group.phraser.widget');

    // Register for background updates (iOS)
    await HomeWidget.registerBackgroundCallback(_backgroundCallback);

    debugPrint('✅ Widget service initialized with App Group');
  } catch (e) {
    debugPrint('❌ Error initializing widget service: $e');
  }
}
```

## Step 7: Build and Run

1. In Xcode, select **Runner** scheme (top left)
2. Select your device or simulator
3. Click **Run** (▶️) button
4. Wait for app to launch

## Step 8: Test Widget Data

In your app, call the widget service:

```dart
import 'package:phraser/services/widget_service.dart';

// Initialize in main.dart
await WidgetService().initialize();

// Update widget with current quote
await WidgetService().updateWidget();
```

## Step 9: Add Widget to Home Screen

### On Simulator/Device:
1. **Long-press** on home screen
2. Tap **+** icon (top left)
3. Search for **"Phraser"** or scroll to find it
4. Select **Phraser Widget**
5. Choose size (Small or Medium)
6. Tap **Add Widget**
7. Tap **Done**

## Step 10: Verify Widget is Working

The widget should show:
- ✅ Gradient purple/blue background
- ✅ Quote icon at top
- ✅ Quote text in center
- ✅ Category badge at bottom

If you see "Open Phraser app for daily inspiration", the widget is installed but needs data.

## Troubleshooting

### Widget Shows Default Text
**Problem:** Widget displays placeholder text instead of actual quote

**Solution:**
1. Make sure `WidgetService().initialize()` is called in `main.dart`
2. Call `WidgetService().updateWidget()` after data is loaded
3. Check App Group is EXACTLY the same: `group.phraser.widget`
4. Verify both targets have App Groups enabled

### Widget Not Appearing in Widget Gallery
**Problem:** Can't find Phraser widget when adding widgets

**Solution:**
1. Clean build: Product → Clean Build Folder (⌘ + Shift + K)
2. Rebuild app
3. Make sure PhraserWidget target is included in build
4. Check Info.plist exists for PhraserWidget

### Widget Shows Blank/Black
**Problem:** Widget appears but is empty or black

**Solution:**
1. Check Swift code has no syntax errors
2. Verify gradient colors are valid
3. Look for errors in Xcode console
4. Try restarting device/simulator

### Build Errors
**Problem:** "No such module 'WidgetKit'"

**Solution:**
1. Set iOS Deployment Target to 14.0+ for PhraserWidget
2. Select PhraserWidget target → General → Deployment Info
3. Set iOS to 14.0 or higher

### App Group Not Syncing
**Problem:** Data not sharing between app and widget

**Solution:**
1. Delete and re-add App Group capability
2. Verify EXACT same group ID in both targets
3. Clean and rebuild both targets
4. Reinstall app completely

## Testing Checklist

- [ ] Widget Extension created
- [ ] App Groups configured for both targets
- [ ] Swift code added to PhraserWidget.swift
- [ ] App Group ID set in widget_service.dart
- [ ] WidgetService initialized in main.dart
- [ ] updateWidget() called with quote data
- [ ] Widget added to home screen
- [ ] Widget displays quote correctly
- [ ] Quote updates when swiping in app

## Expected Result

When working correctly:
1. Launch app
2. Widget service initializes with App Group
3. Current quote is saved to shared storage
4. Widget reads from shared storage
5. Widget displays beautiful quote card
6. Swiping to new quote updates widget
7. Widget refreshes every hour automatically

## Debug Commands

Add these to your app to debug:

```dart
// Check if widget data is being saved
final data = await WidgetService().getWidgetData();
print('Widget Data: $data');

// Manually update widget
await WidgetService().updateWidgetWithRandomQuote();

// Check if widget is available
final available = await WidgetService().isWidgetAvailable();
print('Widget Available: $available');
```

## Need More Help?

If widget still not working:
1. Check Xcode console for errors
2. Verify App Group IDs match exactly
3. Try on physical device (not just simulator)
4. Delete app completely and reinstall
5. Check iOS version is 14.0+

---

**Important:** The App Group ID `group.phraser.widget` must be EXACTLY the same in:
- Runner target capabilities
- PhraserWidget target capabilities
- Runner.entitlements file
- PhraserWidget.swift code
- widget_service.dart initialization

Any mismatch will prevent data sharing!
