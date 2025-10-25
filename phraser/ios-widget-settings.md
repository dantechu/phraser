# iOS Widget - Apple Developer Account Settings

This document outlines the required settings in your **Apple Developer Account** for the Phraser iOS home widget to work correctly.

---

## Overview

iOS home widgets require specific configurations in your Apple Developer account to enable data sharing between the main app and the widget extension. You do **NOT** need any special settings in App Store Connect - the widget will automatically appear in the iOS widget gallery once your app is published.

---

## Required Account: Apple Developer Portal

All settings must be configured at: **[developer.apple.com/account](https://developer.apple.com/account)**

Navigate to: **Certificates, Identifiers & Profiles**

---

## Step 1: Register App Group

**Purpose:** App Groups allow the main app and widget extension to share data through SharedUserDefaults.

### Steps:

1. Go to [Apple Developer Portal](https://developer.apple.com/account)
2. Click **Certificates, Identifiers & Profiles**
3. Select **Identifiers** from the sidebar
4. Click the dropdown at the top and select **App Groups**
5. Click the **+** button to create a new App Group
6. Configure:
   - **Description:** Phraser Widget Data Sharing
   - **Identifier:** `group.phraser.widget`
7. Click **Continue**
8. Click **Register**

✅ **Result:** Your App Group is now registered and can be used by your app identifiers.

---

## Step 2: Configure Main App Identifier

**Purpose:** Enable the main app to use the App Group for data sharing.

### Steps:

1. In **Identifiers** section, select **App IDs** from the dropdown
2. Find and select your main app identifier: `com.iam.blessed.affirmation`
   - If it doesn't exist, create it first
3. Click **Edit** or the app ID to edit it
4. Scroll down to **App Groups** capability
5. Check the box to enable **App Groups**
6. Click **Configure** button next to App Groups
7. Select the checkbox for: `group.phraser.widget`
8. Click **Continue**
9. Click **Save**

✅ **Result:** Main app can now access the shared App Group.

---

## Step 3: Create Widget Extension Identifier

**Purpose:** Register the widget extension as a separate App ID with App Groups enabled.

### Steps:

1. In **Identifiers** → **App IDs**, click the **+** button
2. Select **App IDs** and click **Continue**
3. Select **App** type and click **Continue**
4. Configure:
   - **Description:** Phraser Widget Extension
   - **Bundle ID:** Explicit
   - **Bundle ID value:** `com.iam.blessed.affirmation.PhraserWidget`
     - ⚠️ Must follow pattern: `<main-app-bundle-id>.PhraserWidget`
5. Scroll down to **Capabilities**
6. Check the box for **App Groups**
7. Click **Continue**
8. Click **Register**
9. After creation, click on the new identifier
10. Click **Configure** next to App Groups
11. Select: `group.phraser.widget`
12. Click **Continue** and **Save**

✅ **Result:** Widget extension identifier is created and linked to the App Group.

---

## Step 4: Create/Update Provisioning Profiles

**Purpose:** Generate provisioning profiles that include the App Groups entitlement.

### For Development Testing:

1. Go to **Profiles** section in the sidebar
2. Click **+** to create new profile

#### Main App Development Profile:

1. Select **iOS App Development**
2. Click **Continue**
3. Select App ID: `com.iam.blessed.affirmation`
4. Click **Continue**
5. Select your development certificate
6. Click **Continue**
7. Select test devices
8. Click **Continue**
9. Name it: `Phraser Dev Profile`
10. Click **Generate**
11. **Download** and double-click to install in Xcode

#### Widget Extension Development Profile:

1. Click **+** to create new profile
2. Select **iOS App Development**
3. Select App ID: `com.iam.blessed.affirmation.PhraserWidget`
4. Click **Continue**
5. Select your development certificate
6. Click **Continue**
7. Select test devices
8. Click **Continue**
9. Name it: `Phraser Widget Dev Profile`
10. Click **Generate**
11. **Download** and double-click to install in Xcode

### For App Store Distribution:

Repeat the same process but select **App Store** instead of **iOS App Development** in step 1.

1. Create **App Store Distribution** profile for main app
2. Create **App Store Distribution** profile for widget extension

✅ **Result:** Both targets have valid provisioning profiles with App Groups enabled.

---

## Step 5: Verify Configuration in Xcode

After completing the above steps, verify in Xcode:

### Main App (Runner Target):

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the **Runner** target
3. Go to **Signing & Capabilities** tab
4. Verify:
   - ✅ **App Groups** capability is listed
   - ✅ `group.phraser.widget` is checked
   - ✅ Provisioning profile is valid (no errors)

### Widget Extension Target:

1. Select the **PhraserWidgetExtension** target
2. Go to **Signing & Capabilities** tab
3. Verify:
   - ✅ **App Groups** capability is listed
   - ✅ `group.phraser.widget` is checked (same as main app)
   - ✅ Provisioning profile is valid (no errors)

---

## Configuration Summary

| Setting | Value |
|---------|-------|
| **App Group ID** | `group.phraser.widget` |
| **Main App Bundle ID** | `com.iam.blessed.affirmation` |
| **Widget Bundle ID** | `com.iam.blessed.affirmation.PhraserWidget` |
| **Capability Required** | App Groups |
| **Account Required** | Apple Developer Portal |
| **App Store Connect Settings** | None required |

---

## App Store Connect - No Settings Needed

**Good News:** You do NOT need to configure anything specific for widgets in App Store Connect.

When you submit your app:
- The widget extension is bundled automatically with the main app
- Users will see the widget in their iOS widget gallery after installing the app
- No special screenshots or descriptions needed (though you can showcase widgets in your app preview)

---

## Common Issues & Solutions

### Issue 1: "App Group not found" Error

**Cause:** App Group not registered or not associated with App ID

**Solution:**
1. Verify App Group exists in Apple Developer Portal
2. Confirm both App IDs have the App Group enabled
3. Regenerate provisioning profiles
4. Clean build in Xcode (Cmd+Shift+K)

---

### Issue 2: Widget Shows Default Data Only

**Cause:** App Group ID mismatch between code and provisioning

**Solution:**
1. Verify `group.phraser.widget` is used in:
   - Runner.entitlements
   - PhraserWidgetExtension.entitlements
   - widget_service.dart (line ~25)
   - PhraserWidget.swift (line ~26)
2. All must match exactly
3. Rebuild both targets

---

### Issue 3: Provisioning Profile Errors in Xcode

**Cause:** Profile doesn't include App Groups or is outdated

**Solution:**
1. Delete old profiles:
   ```bash
   rm -rf ~/Library/MobileDevice/Provisioning\ Profiles/*
   ```
2. Download fresh profiles from Apple Developer Portal
3. Double-click to install
4. In Xcode: Product → Clean Build Folder
5. Rebuild

---

## Before Releasing to App Store

### Final Checklist:

- [ ] App Group `group.phraser.widget` is registered
- [ ] Main app identifier has App Groups enabled
- [ ] Widget extension identifier has App Groups enabled
- [ ] Both identifiers are linked to the same App Group
- [ ] Distribution provisioning profiles created for both targets
- [ ] Profiles downloaded and installed in Xcode
- [ ] Xcode shows no signing errors
- [ ] Widget works correctly in TestFlight
- [ ] Widget works on physical device (not just simulator)

---

## Testing Before Submission

1. **Create Distribution Build:**
   ```bash
   flutter build ios --release
   ```

2. **Upload to TestFlight:**
   - Archive in Xcode: Product → Archive
   - Upload to App Store Connect
   - Wait for processing

3. **Install via TestFlight:**
   - Install app on device
   - Add widget to home screen
   - Verify widget displays data correctly
   - Verify widget updates when app data changes

4. **If widget doesn't work:**
   - Check provisioning profiles include App Groups
   - Verify bundle IDs are correct
   - Confirm App Group ID matches in code and portal

---

## Additional Resources

- [Apple Developer Portal](https://developer.apple.com/account)
- [App Groups Documentation](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_security_application-groups)
- [WidgetKit Documentation](https://developer.apple.com/documentation/widgetkit)
- [Distributing Your App](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases)

---

## Need Help?

If you encounter issues:

1. Check all identifiers and group IDs match exactly
2. Regenerate provisioning profiles after any changes
3. Clean build folder and rebuild
4. Test on physical device (simulator may not show all errors)
5. Verify entitlement files contain the App Group

---

**Last Updated:** 2025-10-25
**Status:** Required for iOS widget functionality
**Related Documentation:** [ios-widget.md](ios-widget.md)
