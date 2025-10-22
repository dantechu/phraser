# Lifetime Premium Setup Instructions

The app has been updated from a monthly subscription model to a **one-time lifetime purchase** at **$4.99**.

## Product ID
- **Product ID**: `lifetime_premium`
- **Type**: Non-consumable (One-time purchase)
- **Price**: $4.99 USD

---

## Apple App Store Configuration (iOS)

### 1. Sign in to App Store Connect
- Go to: https://appstoreconnect.apple.com
- Navigate to: **My Apps** > Select your app

### 2. Create In-App Purchase
1. Go to: **Features** > **In-App Purchases**
2. Click the **+** button to create a new in-app purchase
3. Select: **Non-Consumable**

### 3. Configure Product Details
- **Reference Name**: `Lifetime Premium`
- **Product ID**: `lifetime_premium` (Must match exactly)
- **Price**: Select **$4.99 USD** price tier (Tier 5)

### 4. Localization
Add at least one localization (English):
- **Display Name**: `Lifetime Premium`
- **Description**: `Unlock all features with a one-time payment. No subscription, no recurring charges. Yours forever!`

### 5. App Privacy
- Select: **Does Not Use Advertising or Third-Party Analytics**
- **App Functionality**: Enable if purchase is required for core functionality

### 6. Review Information
- Attach screenshot (if required)
- Review notes: *This is a one-time purchase for lifetime access to premium features*

### 7. Submit for Review
- Click **Submit for Review**
- Apple typically reviews in-app purchases within 24-48 hours

---

## Google Play Store Configuration (Android)

### 1. Sign in to Google Play Console
- Go to: https://play.google.com/console
- Select your app

### 2. Create In-App Product
1. Go to: **Monetize** > **Products** > **In-app products**
2. Click **Create product**

### 3. Configure Product Details
- **Product ID**: `lifetime_premium` (Must match exactly)
- **Name**: `Lifetime Premium`
- **Description**: `Unlock all features with a one-time payment. No subscription, no recurring charges. Yours forever!`

### 4. Pricing
- **Price**: Set to **$4.99 USD**
- Google will automatically convert to other currencies

### 5. Status
- Set status to: **Active**
- Save changes

### 6. Tax Settings (if applicable)
- Configure tax category based on your region
- Most regions: **Digital goods**

---

## Testing

### iOS Testing (Sandbox)
1. In App Store Connect, create a **Sandbox Tester** account
2. Sign out of App Store on your test device
3. Run the app from Xcode
4. When prompted to sign in, use your sandbox tester credentials
5. Test the purchase (you won't be charged)

### Android Testing
1. In Google Play Console, add testers under **Setup** > **License Testing**
2. Add test email addresses
3. Install the app via internal testing track
4. Test purchases will show as "\[Test\] Lifetime Premium"

---

## Code Changes Made

### 1. Updated Product ID
**File**: `lib/payments/view_model/in_app_purchase_view_model.dart`
- Changed from: `basic_monthly_subscription`
- Changed to: `lifetime_premium`

### 2. Updated UI Text
**File**: `lib/screens/in_app_purchase/preimum_app_screen.dart`
- Price: `$1.99/month` → `$4.99 lifetime`
- Button text: `Start Premium - $1.99/month` → `Get Lifetime Premium - $4.99`
- Description: `per month` → `lifetime access`
- Subtext: `Billed monthly • Cancel anytime` → `One-time payment • No subscription`
- Feature: `Cancel anytime` → `Lifetime access`
- Restore text: `Already subscribed?` → `Already purchased?`

---

## Important Notes

### Product Type
- **Non-Consumable** (One-time purchase that doesn't expire)
- **NOT** a subscription
- Users purchase once and own it forever

### Restore Purchases
- The app supports restoring purchases
- Users can restore on new devices or after reinstalling
- iOS: Automatic via App Store
- Android: Via Google Play Billing Library

### Revenue Model
- One-time payment of $4.99
- No recurring revenue
- Better for user retention and simpler UX
- Consider the lifetime value vs subscription model

---

## Checklist Before Launch

- [ ] Create `lifetime_premium` product in App Store Connect
- [ ] Create `lifetime_premium` product in Google Play Console
- [ ] Set price to $4.99 on both platforms
- [ ] Test purchase flow on iOS (sandbox)
- [ ] Test purchase flow on Android (internal testing)
- [ ] Test restore purchases on both platforms
- [ ] Verify premium features unlock after purchase
- [ ] Submit products for review (iOS) / Activate (Android)
- [ ] Update app privacy details if needed
- [ ] Release app update with new purchase model

---

## Support & Troubleshooting

### "Product not found" error
- Ensure product ID is exactly `lifetime_premium` (case-sensitive)
- iOS: Wait 2-4 hours after creating product for it to propagate
- Android: Ensure product status is "Active"

### Purchase not restoring
- iOS: User must be signed in with same Apple ID
- Android: User must be signed in with same Google account
- Check that `verifyPurchase()` method is correctly checking product ID

### Testing Issues
- iOS: Make sure using sandbox account, not production
- Android: Make sure app is installed via internal test track
- Clear app data and try again

---

## Contact Information
If you encounter issues during setup, these are the typical support channels:
- **Apple**: https://developer.apple.com/contact/
- **Google**: https://support.google.com/googleplay/android-developer
