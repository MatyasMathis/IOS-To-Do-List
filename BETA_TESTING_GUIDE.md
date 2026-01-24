# Beta Testing Guide - TestFlight Setup

This guide walks you through distributing your Daily To-Do List app for beta testing using Apple's TestFlight platform.

---

## Overview

**TestFlight** is Apple's official beta testing platform that allows you to:
- Distribute your app to up to **10,000 beta testers**
- Get feedback and crash reports
- Test on real devices before App Store release
- Manage internal (team) and external (public) testers

---

## Prerequisites

### 1. Apple Developer Program Membership
- **Required**: Paid Apple Developer Program ($99/year)
- Free accounts **cannot** use TestFlight
- Sign up at: https://developer.apple.com/programs/

### 2. App Requirements
- ✅ Unique Bundle Identifier
- ✅ App icons for all required sizes
- ✅ Build number must increment with each upload
- ✅ Minimum iOS deployment target set
- ✅ App must not crash on launch

### 3. Required Information
- App name
- App description
- Privacy policy URL (required for external testing)
- Contact email
- App category

---

## Step 1: Prepare Your App for Distribution

### A. Configure App Icons

1. Open `dailytodolist.xcodeproj` in Xcode
2. Navigate to **Assets.xcassets > AppIcon**
3. Add icons for all required sizes:
   - iPhone: 40x40, 60x60, 58x58, 87x87, 80x80, 120x120, 180x180
   - App Store: 1024x1024 (required)

**Tip:** Use a tool like [AppIconMaker](https://appiconmaker.co/) to generate all sizes.

### B. Update App Information

1. Select **dailytodolist** project in Xcode
2. Select **dailytodolist** target
3. Go to **General** tab:
   - **Display Name**: "Daily To-Do List"
   - **Bundle Identifier**: Must be unique (e.g., `com.yourname.dailytodolist`)
   - **Version**: Start with `1.0`
   - **Build**: Start with `1` (increment for each upload)

### C. Set Deployment Target

1. In **General** tab, set **Minimum Deployments**:
   - iOS: 17.0 (or your minimum supported version)

### D. Configure Code Signing

1. Go to **Signing & Capabilities** tab
2. **Uncheck** "Automatically manage signing"
3. Select **Team**: Your Apple Developer Team
4. **Provisioning Profile**: Select "App Store" or let Xcode create one

---

## Step 2: Archive Your App

### A. Select Build Destination

1. In Xcode toolbar, select **"Any iOS Device (arm64)"** as the build destination
   - **Important**: Must select "Any iOS Device", NOT a simulator

### B. Create Archive

1. In menu bar: **Product > Archive**
2. Wait for build to complete (may take a few minutes)
3. **Organizer** window will open automatically

### C. Validate Archive

1. In Organizer, select your latest archive
2. Click **"Validate App"**
3. Select your development team
4. Choose automatic signing or manual
5. Click **"Validate"**
6. Wait for validation (checks for errors)
7. Fix any errors and re-archive if needed

---

## Step 3: Upload to App Store Connect

### A. Distribute App

1. In Organizer, select your archive
2. Click **"Distribute App"**
3. Choose **"App Store Connect"**
4. Click **"Upload"**
5. Select signing method:
   - **Recommended**: Automatically manage signing
6. Review upload summary
7. Click **"Upload"**
8. Wait for upload to complete (may take 10-30 minutes)

### B. Processing Time

- After upload, Apple processes your build
- Processing typically takes **15-60 minutes**
- You'll receive an email when processing completes

---

## Step 4: Set Up App in App Store Connect

### A. Access App Store Connect

1. Go to: https://appstoreconnect.apple.com
2. Sign in with your Apple Developer account
3. Click **"My Apps"**

### B. Create New App (First Time Only)

1. Click **"+"** button > **"New App"**
2. Fill in required information:
   - **Platform**: iOS
   - **Name**: "Daily To-Do List"
   - **Primary Language**: English (or your choice)
   - **Bundle ID**: Select from dropdown (must match Xcode)
   - **SKU**: Unique identifier (e.g., `dailytodolist-001`)
   - **User Access**: Full Access

### C. Configure App Information

1. Go to **App Information** (left sidebar)
2. Fill in:
   - **Category**: Productivity
   - **Content Rights**: Select appropriate option
   - **Age Rating**: Complete questionnaire

### D. Add App Privacy Information

1. Go to **App Privacy** (left sidebar)
2. Click **"Get Started"**
3. Answer questions about data collection:
   - Does your app collect data? (Probably "No" for local-only app)
   - If using SwiftData locally only, you likely don't collect data
4. Publish privacy information

---

## Step 5: Set Up TestFlight

### A. Select Build for Testing

1. In App Store Connect, go to **TestFlight** tab
2. Wait for your build to appear (check email for processing completion)
3. Under **"iOS"**, you'll see your build listed
4. Click on the build number

### B. Add Export Compliance Information

1. Click **"Provide Export Compliance Information"**
2. Answer questions:
   - **Does your app use encryption?**
     - Typically "No" for basic apps
     - HTTPS network calls don't count
   - If "Yes", you'll need to provide additional info
3. Click **"Start Internal Testing"**

### C. Add Beta App Information

1. Go to **TestFlight > App Information**
2. Fill in:
   - **Beta App Description**: Brief description of your app
   - **Feedback Email**: Your email for tester feedback
   - **What to Test**: Instructions for testers (optional)

---

## Step 6: Invite Beta Testers

### Internal Testing (Team Members)

**Internal testers** are members of your App Store Connect team.

1. Go to **TestFlight > Internal Testing**
2. Click **"+"** to create a new group (or use "App Store Connect Users")
3. Name the group (e.g., "Internal Team")
4. Add testers:
   - Click **"+"** next to testers
   - Select team members from your App Store Connect account
5. Enable builds for this group
6. Testers will receive email invitations

**Limitations:**
- Maximum 100 internal testers
- Must be added to App Store Connect team first
- No review required

---

### External Testing (Public Beta)

**External testers** are anyone with a TestFlight invitation.

1. Go to **TestFlight > External Testing**
2. Click **"+"** to create a new group
3. Name the group (e.g., "Public Beta Testers")
4. Add build to group
5. **Submit for Beta App Review** (required for first external build)
   - Apple reviews external builds (typically 24-48 hours)
   - Ensure app doesn't crash and privacy info is complete

6. Add testers:
   - **Option 1: Email Invitation**
     - Click **"+"** to add testers manually
     - Enter email addresses
     - Testers receive invitation link

   - **Option 2: Public Link**
     - Click **"Enable Public Link"**
     - Copy the public link
     - Share link via social media, website, etc.
     - Anyone with link can join (up to 10,000 testers)

**Limitations:**
- Maximum 10,000 external testers
- Requires Beta App Review for first build
- Updates may require re-review if significant changes

---

## Step 7: Testers Install Your App

### Tester Instructions

Send these instructions to your beta testers:

1. **Install TestFlight App**
   - Download "TestFlight" from the App Store
   - It's a free app by Apple

2. **Accept Invitation**
   - **Email invite**: Tap the link in the invitation email
   - **Public link**: Tap the public link you shared
   - Opens TestFlight app automatically

3. **Install Your App**
   - Tap **"Install"** or **"Update"** in TestFlight
   - App installs like a regular App Store app
   - Icon appears on home screen with orange dot (indicates beta)

4. **Provide Feedback**
   - Open TestFlight app
   - Select your app
   - Tap **"Send Beta Feedback"**
   - Describe issues or suggestions
   - Optional: Include screenshot

5. **Check for Updates**
   - TestFlight notifies when new builds are available
   - Updates are optional (testers choose when to update)

---

## Step 8: Manage Beta Testing

### A. Upload New Builds

When you make changes and want to update beta testers:

1. **Increment build number** in Xcode:
   - General tab > Build: `2`, `3`, `4`, etc.
   - Version can stay the same (e.g., `1.0`)

2. **Archive and upload** (repeat Step 2 & 3)

3. In App Store Connect:
   - New build appears in TestFlight after processing
   - Add build to existing test groups
   - Testers receive notification of new build

### B. Monitor Feedback

1. Go to **TestFlight > Testers**
2. View feedback from testers
3. See crash logs and metrics
4. Respond to tester questions

### C. Track Metrics

TestFlight provides useful analytics:
- **Installs**: How many testers installed
- **Sessions**: App usage frequency
- **Crashes**: Crash rate and logs
- **Feedback**: Tester comments and screenshots

---

## Best Practices for Beta Testing

### 1. Start with Internal Testing
- Test with small internal group first
- Fix critical bugs before external testing
- Verify app doesn't crash on launch

### 2. Write Clear Test Instructions
In **"What to Test"** section:
```
Welcome to Daily To-Do List Beta!

Please test:
✅ Adding regular tasks
✅ Adding recurring daily tasks
✅ Completing tasks (should disappear)
✅ Checking history tab
✅ Reordering tasks
✅ Deleting tasks

Known issues:
- None currently

Please report any crashes or unexpected behavior!
```

### 3. Communicate with Testers
- Announce new builds with changelog
- Respond to feedback quickly
- Thank testers for participation

### 4. Manage Build Numbers
- Always increment build number for each upload
- Use semantic versioning for version numbers:
  - `1.0.0` - Initial beta
  - `1.0.1` - Bug fixes
  - `1.1.0` - New features
  - `2.0.0` - Major changes

### 5. Beta Duration Limits
- TestFlight builds expire after **90 days**
- Upload new builds before expiration
- Testers must update to continue testing

---

## Common Issues & Solutions

### "Missing Compliance" Warning
- **Solution**: Add Export Compliance information in App Store Connect
- Go to build > Provide Export Compliance Information

### "Missing Privacy Policy"
- **Solution**: Required for external testing
- Create simple privacy policy page
- Add URL in App Store Connect > App Information

### Build Not Appearing in TestFlight
- **Wait**: Processing can take up to 60 minutes
- **Check email**: Apple sends status updates
- **Verify**: Check Xcode Organizer upload succeeded

### Testers Can't Install
- **Verify**: Tester accepted invitation
- **Check**: Build is enabled for their group
- **iOS Version**: Ensure tester's iOS version meets minimum deployment target
- **Device**: Ensure compatible device (your app supports iPhone 11+)

### Upload Failed
- **Fix validation errors** in Xcode
- **Check Bundle ID** matches App Store Connect
- **Verify signing** uses correct team and certificate
- **Ensure icons** are all added

---

## Quick Reference: Build Upload Checklist

Before each upload:

- [ ] Increment **Build number** in Xcode
- [ ] Test app on device (no crashes)
- [ ] All app icons added (including 1024x1024)
- [ ] Build destination set to **"Any iOS Device"**
- [ ] Product > Archive completed successfully
- [ ] Archive validated without errors
- [ ] Archive uploaded to App Store Connect
- [ ] Export compliance information provided
- [ ] Build added to TestFlight groups
- [ ] Testers notified of new build
- [ ] Changelog/notes added for testers

---

## Next Steps After Beta Testing

Once beta testing is complete and you're ready to release:

1. **Submit for App Store Review**
   - Create App Store version in App Store Connect
   - Add screenshots, description, keywords
   - Submit for review
   - Typical review time: 24-48 hours

2. **Release**
   - After approval, release to App Store
   - Choose manual or automatic release
   - App goes live!

---

## Helpful Resources

- **App Store Connect**: https://appstoreconnect.apple.com
- **TestFlight Help**: https://developer.apple.com/testflight/
- **App Review Guidelines**: https://developer.apple.com/app-store/review/guidelines/
- **Human Interface Guidelines**: https://developer.apple.com/design/human-interface-guidelines/

---

## Support

If you encounter issues:
1. Check Apple Developer Forums: https://developer.apple.com/forums/
2. Review App Store Connect Help: https://help.apple.com/app-store-connect/
3. Contact Apple Developer Support (with paid membership)

---

**Good luck with your beta testing! 🚀**
