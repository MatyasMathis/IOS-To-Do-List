# Sandbox Testing Guide for REPS Pro

This guide explains how to set up and use Apple's Sandbox environment to test the "REPS Pro" in-app purchase (`com.mathis.reps.pro`) on a physical iPhone.

## Prerequisites

- An [App Store Connect](https://appstoreconnect.apple.com) account with Admin or App Manager role
- A physical iPhone running iOS 17.4+
- Xcode with the project configured for your development team

---

## 1. Create a Sandbox Tester in App Store Connect

1. Open [App Store Connect](https://appstoreconnect.apple.com).
2. Go to **Users and Access** > **Sandbox** (sidebar).
3. Click **"+"** to add a new sandbox tester.
4. Fill in the details:
   | Field | Notes |
   |---|---|
   | First / Last Name | Any value (e.g. "Test User") |
   | Email | A real, accessible email that is **not** an existing Apple ID |
   | Password | Must meet Apple password requirements |
   | Territory | Select the App Store region to test |
5. Click **Save**.
6. Check your email and verify if prompted.

---

## 2. Sign In to the Sandbox Account on iPhone

1. Open **Settings** on your iPhone.
2. Scroll down and tap **App Store**.
3. Scroll to the bottom — find the **Sandbox Account** section.
4. Tap **Sign In** and enter the sandbox tester credentials.

> **Important:** On iOS 17+, the sandbox account is completely separate from your personal Apple ID. You do **not** need to sign out of your main account.

---

## 3. Run the App and Test Purchases

1. In Xcode, build and run the app on your physical device.
2. Open the paywall (tap a Pro-gated feature or navigate via Settings).
3. Tap the **Purchase** button for "REPS Pro" ($4.99).
4. The payment sheet will show **[Environment: Sandbox]**.
5. Confirm the purchase — **no real money is charged**.
6. `StoreKitService` processes the transaction and unlocks Pro features.

---

## 4. Alternative: Xcode StoreKit Local Testing

For faster iteration without a sandbox account, use the included `Products.storekit` configuration:

1. In Xcode, go to **Product > Scheme > Edit Scheme**.
2. Under **Run > Options**, set **StoreKit Configuration** to `Products.storekit`.
3. Run in the Simulator or on a device.
4. Purchases are handled locally by Xcode — no App Store Connect needed.
5. Use **Debug > StoreKit > Manage Transactions** in Xcode to view, approve, or refund test transactions.

---

## 5. Debug Toggle (Simulator Only)

In `DEBUG` builds, `StoreKitService` includes a `debugTogglePro()` method that instantly toggles Pro status without any purchase flow. This is useful for quickly testing Pro-gated UI.

---

## 6. Testing Checklist

- [ ] **Purchase flow**: Tap purchase, confirm, verify Pro features unlock
- [ ] **Restore purchases**: Delete app, reinstall, tap "Restore Purchases" on paywall
- [ ] **Error handling**: Simulate errors via the `Products.storekit` configuration (enable error options in Xcode)
- [ ] **Transaction listener**: Background the app, complete a purchase, return — verify state updates
- [ ] **Cancel/refund**: Use Xcode's StoreKit transaction manager to refund, verify Pro is revoked

---

## 7. Resetting Sandbox State

- **On device**: Settings > App Store > Sandbox Account — manage or sign out
- **In App Store Connect**: You can create new sandbox testers at any time
- **In Xcode (local testing)**: Debug > StoreKit > Manage Transactions — delete all transactions

---

## Troubleshooting

| Issue | Solution |
|---|---|
| "Cannot connect to iTunes Store" | Ensure device has internet; sandbox servers may be down — retry later |
| Purchase sheet doesn't appear | Verify `Products.storekit` is set in scheme, or that sandbox account is signed in |
| Pro not unlocking after purchase | Check `StoreKitService` logs; ensure `transaction.finish()` is called |
| Sandbox account won't sign in | Verify email, reset password in App Store Connect |
| Payment sheet shows real prices | This is expected — sandbox uses real prices but never charges |
