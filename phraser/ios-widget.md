# iOS Widget Setup - Manual Steps Required

This document outlines the manual steps required to complete the iOS widget setup for the Phraser app. The widget code is already implemented, but certain configurations must be done through Xcode.

---

## Overview

The iOS widget displays quotes from the Phraser app on the iOS home screen, similar to the Android widget. The implementation uses:
- **WidgetKit** framework for iOS widgets
- **App Groups** for data sharing between the main app and widget
- **SharedUserDefaults** with suite name `group.phraser.widget`

---

## Current Implementation Status

✅ **Completed:**
- Widget Swift code implemented ([ios/PhraserWidget/PhraserWidget.swift](ios/PhraserWidget/PhraserWidget.swift))
- App Group entitlements configured in both Runner and PhraserWidget
- Widget service in Flutter ([lib/services/widget_service.dart](lib/services/widget_service.dart))
- Data saving mechanism using `home_widget` package
- Widget UI matching Android design (gradient background, quote icon, category badge)

⚠️ **Requires Manual Configuration in Xcode:**

---

## Manual Steps Required

### 0. **🚨 CRITICAL: Embed Widget Extension in Runner App**

**Why:** The widget extension must be embedded in the main app for it to appear in the widget picker.

**⚠️ This is the #1 reason widgets don't appear - do this step first!**

**Steps:**
1. Open `ios/Runner.xcworkspace` in Xcode (NOT `.xcodeproj`)
2. Select the `Runner` project in the Project Navigator (blue icon at top)
3. Select the `Runner` target (under TARGETS section)
4. Go to **Build Phases** tab
5. Find the **Embed Foundation Extensions** section
6. Click the **+** button
7. Select `PhraserWidgetExtension.appex` from the list
8. Ensure it shows in the list (not grayed out)
9. Clean build: **Product** → **Clean Build Folder** (Cmd+Shift+K)
10. Rebuild and run the app
11. After app installs, long-press home screen → tap **+** → search "Phraser"

**Verification:**
After building, verify the widget is embedded:
```bash
ls -la build/ios/Debug-iphonesimulator/Runner.app/PlugIns/
```
You should see `PhraserWidgetExtension.appex` folder.

If the folder doesn't exist, the widget won't appear in the widget picker!

---

### 1. Verify Widget Target in Xcode

**Why:** Ensure the PhraserWidget extension target is properly configured in the Xcode project.

**Steps:**
1. Open `ios/Runner.xcworkspace` in Xcode (NOT `.xcodeproj`)
2. In the Project Navigator, verify you can see:
   - `Runner` (main app target)
   - `PhraserWidgetExtension` (widget extension target)
3. If PhraserWidgetExtension target is missing, you'll need to create it (see Section 6)

---

### 2. Configure App Groups in Xcode

**Why:** App Groups allow the main app and widget extension to share data through SharedUserDefaults.

**Steps:**

#### For Runner (Main App):
1. Select the `Runner` project in Xcode
2. Select the `Runner` target (under TARGETS)
3. Go to **Signing & Capabilities** tab
4. Verify **App Groups** capability exists
5. If not present, click **+ Capability** and add **App Groups**
6. Check the box for `group.phraser.widget`
7. **Important:** This must match your Apple Developer account

#### For PhraserWidget Extension:
1. Select the `PhraserWidget` target (under TARGETS)
2. Go to **Signing & Capabilities** tab
3. Verify **App Groups** capability exists
4. If not present, click **+ Capability** and add **App Groups**
5. Check the box for `group.phraser.widget`
6. **Important:** Must be identical to the main app's group ID

**Verification:**
- Both entitlement files should already contain:
  ```xml
  <key>com.apple.security.application-groups</key>
  <array>
      <string>group.phraser.widget</string>
  </array>
  ```

---

### 3. Configure Bundle Identifiers

**Why:** Widget extensions require specific bundle identifier naming.

**Steps:**
1. Select `Runner` target
2. Go to **General** tab
3. Note the **Bundle Identifier** (e.g., `com.iam.blessed.affirmation`)
4. Select `PhraserWidget` target
5. Set **Bundle Identifier** to: `<main-bundle-id>.PhraserWidget`
   - Example: `com.iam.blessed.affirmation.PhraserWidget`

---

### 4. Configure Signing & Provisioning

**Why:** Both targets need valid signing certificates and provisioning profiles.

**Steps:**

#### For Development:
1. Select `Runner` target → **Signing & Capabilities**
2. Enable **Automatically manage signing**
3. Select your **Team**
4. Repeat for `PhraserWidget` target
5. Use the same **Team** for both targets

#### For Production/Release:
1. Go to [Apple Developer Portal](https://developer.apple.com)
2. Create **App IDs** for both:
   - Main app: `com.iam.blessed.affirmation`
   - Widget: `com.iam.blessed.affirmation.PhraserWidget`
3. Enable **App Groups** capability for both App IDs
4. Create/update **Provisioning Profiles** for both:
   - Ensure App Groups entitlement is included
   - Download and install in Xcode
5. In Xcode, disable automatic signing and select the profiles manually

---

### 5. Register App Group in Apple Developer Portal

**Why:** App Groups must be registered with your Apple Developer account.

**Steps:**
1. Go to [Apple Developer Portal](https://developer.apple.com/account)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Select **Identifiers** → **App Groups**
4. Click **+** to create new App Group (if not exists)
5. Enter identifier: `group.phraser.widget`
6. Add description: "Phraser Widget Data Sharing"
7. Click **Continue** and **Register**

**Then, add to App IDs:**
1. Go to **Identifiers** → **App IDs**
2. Select your main app ID (`com.iam.blessed.affirmation`)
3. Edit and enable **App Groups** capability
4. Select `group.phraser.widget`
5. Save
6. Repeat for widget extension App ID (`com.iam.blessed.affirmation.PhraserWidget`)

---

### 6. Create Widget Extension Target (If Missing)

**Why:** If the PhraserWidget target doesn't exist in Xcode, you need to create it.

**Steps:**
1. In Xcode, select **File** → **New** → **Target**
2. Choose **Widget Extension**
3. Click **Next**
4. Configure:
   - **Product Name:** PhraserWidget
   - **Team:** Your team
   - **Organization Identifier:** `com.iam.blessed.affirmation`
   - **Include Configuration Intent:** Unchecked
5. Click **Finish**
6. When prompted "Activate 'PhraserWidget' scheme?", click **Activate**
7. Delete the auto-generated Swift file
8. Add the existing [PhraserWidget.swift](ios/PhraserWidget/PhraserWidget.swift) file to the target
9. Follow steps 2-4 above to configure App Groups and signing

---

### 7. Update Info.plist (If Needed)

**Why:** Ensure widget extension metadata is correct.

**Steps:**
1. Open `ios/PhraserWidget/Info.plist`
2. Verify it contains:
   ```xml
   <key>NSExtension</key>
   <dict>
       <key>NSExtensionPointIdentifier</key>
       <string>com.apple.widgetkit-extension</string>
   </dict>
   ```
3. This should already be configured correctly

---

### 8. Add Widget Icon/Assets (Optional)

**Why:** Widgets can have custom icons in the widget picker.

**Steps:**
1. In Xcode, open `Assets.xcassets` for PhraserWidget target
2. Create a new **App Icon** set
3. Add icon images for different sizes:
   - 1024x1024 (required)
   - Additional sizes as needed
4. This is optional but improves user experience

---

### 9. Build and Test the Widget

**Why:** Verify everything works correctly.

**Steps:**

#### Test on Simulator:
1. Select the `PhraserWidget` scheme in Xcode
2. Choose an iOS Simulator (iOS 14.0+)
3. Click **Run** (Play button)
4. Xcode will launch the widget picker
5. Select your widget size (Small or Medium)
6. The widget should display with placeholder data

#### Test on Physical Device:
1. Connect your iOS device
2. Select `Runner` scheme
3. Build and run the main app
4. Open the app and ensure widget data is updated:
   - Widget service should save quote data
   - Check console for "✅ Widget updated" logs
5. Exit the app
6. Long-press home screen → tap **+** → search "Phraser"
7. Add the widget to home screen
8. Widget should display the current quote from the app

---

### 10. Verify Data Flow

**Why:** Ensure the main app and widget can communicate.

**Steps:**

1. **Run the main Flutter app:**
   ```bash
   flutter run
   ```

2. **Check widget initialization logs:**
   - Look for: `✅ Widget service initialized with App Group: group.phraser.widget`

3. **Trigger widget update:**
   - Navigate through quotes in the app
   - Each quote change should log: `✅ Widget updated with quote: ...`

4. **Verify SharedUserDefaults:**
   - Add temporary debug code in PhraserWidget.swift:
   ```swift
   private func loadEntry() -> SimpleEntry {
       let sharedDefaults = UserDefaults(suiteName: "group.phraser.widget")
       print("DEBUG: SharedDefaults exists: \(sharedDefaults != nil)")

       let quote = sharedDefaults?.string(forKey: "quote_text") ?? "Default"
       print("DEBUG: Loaded quote: \(quote)")

       // ... rest of code
   }
   ```

5. **Check widget updates:**
   - Widget should refresh when you change quotes in the app
   - May take a few seconds for iOS to update the widget display

---

## Common Build Errors & Solutions

### Error: 'buildExpression' is only available in iOS 18.0+

**Error Message:**
```
Swift Compiler Error: 'buildExpression' is only available in application extensions for iOS 18.0 or newer
/ios/PhraserWidget/PhraserWidgetBundle.swift
```

**Cause:** The PhraserWidgetBundle.swift file was trying to include iOS 18+ features (ControlWidget and LiveActivity).

**Solution:** ✅ **FIXED** - The following files have been updated with proper availability guards:
- `PhraserWidgetBundle.swift` - Removed iOS 18+ widgets from bundle
- `PhraserWidgetControl.swift` - Added `@available(iOS 18.0, *)` guards
- `PhraserWidgetLiveActivity.swift` - Added `@available(iOS 16.1, *)` guards
- `PhraserWidget.swift` - Restored proper quote display implementation

The widget now supports iOS 14+ and should build successfully.

---

### Multiple @main Errors

**Cause:** Both PhraserWidget.swift and PhraserWidgetBundle.swift had `@main` attribute.

**Solution:** ✅ **FIXED** - Only `PhraserWidget.swift` has `@main` now. The Bundle file is commented out.

---

### Dependency Cycle Error

**Error Message:**
```
Target 'Runner' has copy command from 'PhraserWidgetExtension.appex' to 'Runner.app/PlugIns/PhraserWidgetExtension.appex'
That command depends on command in Target 'Runner': script phase "[CP] Copy Pods Resources"
Dependency cycle detected
```

**Cause:** The widget extension target and Runner target have a circular dependency through CocoaPods.

**Solution ✅ (APPLIED):**

I've already updated your `ios/Podfile` to fix this. Now follow these steps:

**Step 1: Run pod install**
```bash
cd ios
pod install
cd ..
```

**Step 2: Clean CocoaPods Build Phases in Xcode**
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the Runner project → `PhraserWidgetExtension` target
3. Go to **Build Phases** tab
4. Look for these sections and **delete them** if present:
   - `[CP] Copy Pods Resources`
   - `[CP] Embed Pods Frameworks`
   - `[CP] Check Pods Manifest.lock`
5. The widget extension should NOT have any CocoaPods phases

**Step 3: Verify Embed is Correct & FIX BUILD PHASE ORDER**
1. Select the `Runner` target (not PhraserWidgetExtension)
2. Go to **Build Phases** tab
3. Find **Embed Foundation Extensions**
4. Verify `PhraserWidgetExtension.appex` is listed there
5. **🚨 CRITICAL:** **Drag "Embed Foundation Extensions" to be the LAST build phase**
   - Click and drag it below all other phases
   - This prevents the circular dependency
   - Final order should be:
     - Dependencies
     - [CP-User] Run Script
     - Compile Sources
     - Link Binary With Libraries
     - [CP] Embed Pods Frameworks
     - [CP] Copy Pods Resources
     - Thin Binary
     - Copy Bundle Resources
     - **Embed Foundation Extensions** ← Must be LAST

**Step 4: Clean and Rebuild**
1. In Xcode: **Product** → **Clean Build Folder** (Cmd+Shift+K)
2. Close Xcode
3. Run: `flutter clean && flutter pub get`
4. Run: `flutter run`

**What was changed in Podfile:**
```ruby
# Widget extension target - no pods needed
target 'PhraserWidgetExtension' do
  use_frameworks!
  use_modular_headers!
  # Widget extension doesn't need any pods
  # This prevents dependency cycle issues
end
```

This tells CocoaPods to recognize the widget target but not add any pods to it, preventing the circular dependency.

---

## Troubleshooting

### Widget Shows Default Text Only

**Cause:** App Group not configured correctly or data not being saved.

**Solutions:**
1. Verify both targets have identical App Group ID: `group.phraser.widget`
2. Check entitlements files contain the App Group
3. Rebuild both targets after any entitlement changes
4. Check console logs for widget service errors
5. Verify provisioning profiles include App Groups capability

---

### Widget Target Missing in Xcode

**Cause:** Widget extension target was not properly created.

**Solution:**
- Follow Section 6 to create the widget extension target
- Ensure PhraserWidget.swift is added to the target's build phases

---

### Widget Not Appearing in Widget Picker

**Cause:** Widget extension not properly installed or bundle ID incorrect.

**Solutions:**
1. Clean build folder: **Product** → **Clean Build Folder**
2. Delete app from device/simulator
3. Rebuild and reinstall
4. Verify bundle identifier ends with `.PhraserWidget`
5. Check minimum iOS deployment target is 14.0+

---

### Signing Errors

**Cause:** Provisioning profile or certificate issues.

**Solutions:**
1. For development: Use automatic signing
2. For production: Create explicit provisioning profiles for both targets
3. Ensure App Groups capability is enabled in profiles
4. Regenerate profiles if needed
5. Clear provisioning profile cache:
   ```bash
   rm -rf ~/Library/MobileDevice/Provisioning\ Profiles/*
   ```
   Then download fresh profiles from Apple Developer Portal

---

### Widget Data Not Updating

**Cause:** SharedUserDefaults not accessible or timeline not refreshing.

**Solutions:**
1. Verify App Group ID matches exactly in:
   - Runner.entitlements
   - PhraserWidget.entitlements
   - widget_service.dart (line 25)
   - PhraserWidget.swift (line 26)
2. Check all IDs are: `group.phraser.widget`
3. Restart device/simulator after entitlement changes
4. Force kill and restart the app

---

## Testing Checklist

Before considering the widget complete, test the following:

- [ ] Widget appears in iOS widget picker
- [ ] Small widget size displays correctly
- [ ] Medium widget size displays correctly
- [ ] Widget shows default text when no data available
- [ ] Widget updates when quote changes in app
- [ ] Widget displays correct quote text
- [ ] Widget displays correct category name
- [ ] Widget gradient background renders correctly
- [ ] Quote icon appears at top
- [ ] Category badge appears at bottom
- [ ] Tapping widget opens the app
- [ ] Widget works on iOS Simulator
- [ ] Widget works on physical device
- [ ] Widget persists after app restart
- [ ] Widget updates after app is closed

---

## Files Reference

### iOS Widget Files
- **Widget Code:** [ios/PhraserWidget/PhraserWidget.swift](ios/PhraserWidget/PhraserWidget.swift)
- **Widget Entitlements:** [ios/PhraserWidget/PhraserWidget.entitlements](ios/PhraserWidget/PhraserWidget.entitlements)
- **Widget Info.plist:** [ios/PhraserWidget/Info.plist](ios/PhraserWidget/Info.plist)

### Main App Files
- **Runner Entitlements:** [ios/Runner/Runner.entitlements](ios/Runner/Runner.entitlements)
- **Widget Service:** [lib/services/widget_service.dart](lib/services/widget_service.dart)

### Android Widget Files (For Reference)
- **Widget Provider:** [android/app/src/main/kotlin/com/iam/blessed/affirmation/PhraserWidgetProvider.kt](android/app/src/main/kotlin/com/iam/blessed/affirmation/PhraserWidgetProvider.kt)
- **Widget Layout:** [android/app/src/main/res/layout/phraser_widget.xml](android/app/src/main/res/layout/phraser_widget.xml)

---

## Key Configuration Values

**App Group ID:** `group.phraser.widget`

**Widget Kind:** `PhraserWidget`

**Bundle ID Pattern:** `<main-app-bundle-id>.PhraserWidget`

**Supported Widget Sizes:** Small, Medium

**Minimum iOS Version:** 14.0

**Data Keys:**
- `quote_text` - The quote string
- `quote_category` - Category name
- `has_data` - Boolean flag
- `last_updated` - ISO 8601 timestamp

---

## Next Steps After Manual Configuration

Once all manual steps are completed:

1. **Test thoroughly** using the checklist above
2. **Commit changes** to Xcode project files
3. **Document** any custom bundle IDs or App Group IDs used
4. **Update** provisioning profiles before releasing to App Store
5. **Test** on multiple iOS versions (14.0+)

---

## Additional Resources

- [Apple WidgetKit Documentation](https://developer.apple.com/documentation/widgetkit)
- [App Groups Documentation](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_security_application-groups)
- [home_widget Flutter Package](https://pub.dev/packages/home_widget)

---

**Last Updated:** 2025-10-19
**Widget Implementation:** Complete (Requires Xcode configuration)
