# Strava-Style Share Feature Implementation Plan

## Overview

Add a Strava-inspired share feature that allows users to share their task completions and daily progress with a personal photo. This creates a viral growth loop where users share their wins to social media, driving organic app discovery.

**Target**: Make "Reps" the only to-do app with photo-based achievement sharing.

---

## User Stories

1. **As a user**, when I complete a task, I want to share my accomplishment with a photo so my friends can see what I achieved.

2. **As a user**, when I complete all my daily tasks, I want to share a "day complete" card with my streak so I can flex my consistency.

3. **As a user**, I want my shared cards to look premium and match the app's athletic aesthetic so I'm proud to post them.

---

## Share Card Designs

### Card Type 1: Single Task Completion

```
┌─────────────────────────────────────┐
│                                     │
│                                     │
│          [USER'S PHOTO]             │
│           (Full bleed)              │
│                                     │
│                                     │
├─────────────────────────────────────┤
│  ✓ Morning workout                  │
│  ───────────────────────────────    │
│  🏷️ Health    🔥 12 day streak      │
│                                     │
│  Feb 4, 2026              [REPS]    │
└─────────────────────────────────────┘
```

**Elements:**
- User photo (top 65% of card)
- Task name with checkmark
- Category badge (color-coded)
- Current streak (flame icon)
- Date
- App logo/wordmark (bottom right)

### Card Type 2: Day Complete

```
┌─────────────────────────────────────┐
│                                     │
│                                     │
│          [USER'S PHOTO]             │
│           (Full bleed)              │
│                                     │
│                                     │
├─────────────────────────────────────┤
│  DAY CRUSHED                        │
│  ───────────────────────────────    │
│  ✓ 7/7 tasks    🔥 12 day streak    │
│                                     │
│  Feb 4, 2026              [REPS]    │
└─────────────────────────────────────┘
```

**Elements:**
- User photo (top 65% of card)
- "DAY CRUSHED" headline (randomize: "ALL DONE", "CRUSHED IT", etc.)
- Tasks completed count
- Current streak
- Date
- App logo/wordmark

### Card Type 3: Streak Milestone

```
┌─────────────────────────────────────┐
│                                     │
│                                     │
│          [USER'S PHOTO]             │
│           (Full bleed)              │
│                                     │
│                                     │
├─────────────────────────────────────┤
│  🔥 30 DAY STREAK                   │
│  ───────────────────────────────    │
│  Consistency is my superpower       │
│                                     │
│  Feb 4, 2026              [REPS]    │
└─────────────────────────────────────┘
```

**Trigger**: Milestones at 7, 14, 21, 30, 50, 100 days

---

## User Flow

### Flow 1: Share After Task Completion

```
User completes task
        ↓
Celebration overlay appears (existing)
        ↓
"Share your win?" button appears
        ↓
[User taps "Share"]
        ↓
Camera opens (or photo picker)
        ↓
User takes/selects photo
        ↓
Preview screen with card overlay
        ↓
[Optional] User adds caption
        ↓
Share sheet opens (Instagram, TikTok, Save, etc.)
```

### Flow 2: Share Day Complete

```
User completes LAST task of the day
        ↓
Special "Day Crushed!" celebration
        ↓
"Share your perfect day?" prompt
        ↓
Same photo flow as above
        ↓
Day Complete card generated
```

### Flow 3: Share from History/Stats

```
User views History or Stats
        ↓
Taps share button in toolbar
        ↓
Selects what to share:
  - Today's progress
  - Specific task stats
  - Weekly summary
        ↓
Photo capture/picker
        ↓
Card generated + share
```

---

## Technical Implementation

### Phase 1: Core Infrastructure (Week 1)

#### 1.1 Create ShareService

**File**: `/dailytodolist/Services/ShareService.swift`

```swift
import SwiftUI
import UIKit

@MainActor
class ShareService: ObservableObject {

    enum ShareCardType {
        case taskCompletion(task: TodoTask, streak: Int)
        case dayComplete(tasksCompleted: Int, totalTasks: Int, streak: Int)
        case streakMilestone(streak: Int)
    }

    /// Generate share card image with user photo
    func generateShareCard(
        type: ShareCardType,
        userPhoto: UIImage,
        date: Date = Date()
    ) -> UIImage? {
        // Implementation using ImageRenderer (iOS 16+)
    }

    /// Present system share sheet
    func share(image: UIImage, from viewController: UIViewController) {
        let activityVC = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        viewController.present(activityVC, animated: true)
    }
}
```

#### 1.2 Create Share Card Views

**File**: `/dailytodolist/Components/Share/ShareCardView.swift`

```swift
import SwiftUI

struct TaskCompletionCard: View {
    let task: TodoTask
    let streak: Int
    let userPhoto: UIImage
    let date: Date

    var body: some View {
        VStack(spacing: 0) {
            // Photo section (65%)
            Image(uiImage: userPhoto)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 400)
                .clipped()

            // Stats section (35%)
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(ColorPalette.recoveryGreen)
                    Text(task.title)
                        .font(Typography.headline)
                        .foregroundColor(ColorPalette.pureWhite)
                }

                Divider()
                    .background(ColorPalette.darkGray2)

                HStack {
                    CategoryBadge(category: task.category)
                    Spacer()
                    StreakBadge(count: streak)
                }

                HStack {
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                        .font(Typography.caption)
                        .foregroundColor(ColorPalette.mediumGray)
                    Spacer()
                    Text("REPS")
                        .font(Typography.caption.bold())
                        .foregroundColor(ColorPalette.pureWhite)
                }
            }
            .padding(Spacing.md)
            .background(ColorPalette.brandBlack)
        }
        .frame(width: 390, height: 620) // Instagram Story ratio
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct DayCompleteCard: View {
    let tasksCompleted: Int
    let totalTasks: Int
    let streak: Int
    let userPhoto: UIImage
    let date: Date

    // Similar structure with "DAY CRUSHED" headline
}

struct StreakMilestoneCard: View {
    let streak: Int
    let userPhoto: UIImage
    let date: Date

    // Similar structure with milestone celebration
}
```

#### 1.3 Image Rendering Utility

**File**: `/dailytodolist/Services/ImageRenderer+Extensions.swift`

```swift
import SwiftUI

extension View {
    @MainActor
    func renderAsImage(scale: CGFloat = 3.0) -> UIImage? {
        let renderer = ImageRenderer(content: self)
        renderer.scale = scale
        return renderer.uiImage
    }
}
```

### Phase 2: Photo Capture (Week 1)

#### 2.1 Photo Picker Sheet

**File**: `/dailytodolist/Components/Share/PhotoPickerSheet.swift`

```swift
import SwiftUI
import PhotosUI

struct PhotoPickerSheet: View {
    @Binding var selectedImage: UIImage?
    @Binding var isPresented: Bool
    @State private var showCamera = false
    @State private var showPhotoLibrary = false
    @State private var photosPickerItem: PhotosPickerItem?

    var body: some View {
        VStack(spacing: Spacing.md) {
            Text("Add a photo")
                .font(Typography.headline)

            // Camera button
            Button(action: { showCamera = true }) {
                Label("Take Photo", systemImage: "camera.fill")
            }
            .buttonStyle(PrimaryButtonStyle())

            // Photo library button
            PhotosPicker(
                selection: $photosPickerItem,
                matching: .images
            ) {
                Label("Choose from Library", systemImage: "photo.fill")
            }
            .buttonStyle(SecondaryButtonStyle())

            // Skip option
            Button("Skip photo") {
                selectedImage = nil
                isPresented = false
            }
            .foregroundColor(ColorPalette.mediumGray)
        }
        .padding()
        .fullScreenCover(isPresented: $showCamera) {
            CameraView(image: $selectedImage)
        }
        .onChange(of: photosPickerItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedImage = image
                    isPresented = false
                }
            }
        }
    }
}
```

#### 2.2 Camera View (UIKit wrapper)

**File**: `/dailytodolist/Components/Share/CameraView.swift`

```swift
import SwiftUI
import UIKit

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
```

### Phase 3: Share Flow Integration (Week 2)

#### 3.1 Share Preview Screen

**File**: `/dailytodolist/Views/SharePreviewView.swift`

```swift
import SwiftUI

struct SharePreviewView: View {
    let cardType: ShareService.ShareCardType
    let userPhoto: UIImage

    @StateObject private var shareService = ShareService()
    @Environment(\.dismiss) var dismiss
    @State private var generatedImage: UIImage?

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.lg) {
                // Preview
                if let image = generatedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 500)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(radius: 10)
                }

                Spacer()

                // Share button
                Button(action: shareImage) {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())

                // Save button
                Button(action: saveToPhotos) {
                    Label("Save to Photos", systemImage: "square.and.arrow.down")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            .padding()
            .background(ColorPalette.brandBlack)
            .navigationTitle("Share Your Win")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                generateCard()
            }
        }
    }

    private func generateCard() {
        generatedImage = shareService.generateShareCard(
            type: cardType,
            userPhoto: userPhoto
        )
    }

    private func shareImage() {
        guard let image = generatedImage else { return }
        // Present share sheet
    }

    private func saveToPhotos() {
        guard let image = generatedImage else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        // Show confirmation
    }
}
```

#### 3.2 Integrate into TaskListView

**File**: Modify `/dailytodolist/Views/TaskListView.swift`

```swift
// Add state variables
@State private var showSharePrompt = false
@State private var showPhotoPicker = false
@State private var sharePhoto: UIImage?
@State private var pendingShareTask: TodoTask?
@State private var showSharePreview = false

// Modify completeTask() function
private func completeTask(_ task: TodoTask) {
    let taskService = TaskService(modelContext: modelContext)
    let isNowCompleted = taskService.toggleTaskCompletion(task)

    if isNowCompleted {
        celebrationMessage = EncouragingMessages.random()
        showCelebration = true

        // After celebration, prompt for share
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            pendingShareTask = task
            showSharePrompt = true
        }
    }

    withAnimation {
        updateTodayTasks()
    }
}

// Add share prompt overlay
.overlay {
    if showSharePrompt {
        SharePromptOverlay(
            onShare: {
                showSharePrompt = false
                showPhotoPicker = true
            },
            onSkip: {
                showSharePrompt = false
                pendingShareTask = nil
            }
        )
    }
}
.sheet(isPresented: $showPhotoPicker) {
    PhotoPickerSheet(selectedImage: $sharePhoto, isPresented: $showPhotoPicker)
}
.fullScreenCover(isPresented: $showSharePreview) {
    if let task = pendingShareTask, let photo = sharePhoto {
        SharePreviewView(
            cardType: .taskCompletion(task: task, streak: currentStreak),
            userPhoto: photo
        )
    }
}
.onChange(of: sharePhoto) { _, newPhoto in
    if newPhoto != nil {
        showSharePreview = true
    }
}
```

#### 3.3 Share Prompt Overlay

**File**: `/dailytodolist/Components/Share/SharePromptOverlay.swift`

```swift
import SwiftUI

struct SharePromptOverlay: View {
    let onShare: () -> Void
    let onSkip: () -> Void

    @State private var opacity = 0.0
    @State private var scale = 0.8

    var body: some View {
        ZStack {
            // Background dim
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { onSkip() }

            // Prompt card
            VStack(spacing: Spacing.md) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 40))
                    .foregroundColor(ColorPalette.recoveryGreen)

                Text("Share your win?")
                    .font(Typography.headline)
                    .foregroundColor(ColorPalette.pureWhite)

                Text("Add a photo and flex your productivity")
                    .font(Typography.body)
                    .foregroundColor(ColorPalette.mediumGray)
                    .multilineTextAlignment(.center)

                Button(action: onShare) {
                    Text("Add Photo & Share")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())

                Button("Maybe later", action: onSkip)
                    .foregroundColor(ColorPalette.mediumGray)
            }
            .padding(Spacing.lg)
            .background(ColorPalette.darkGray1)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal, Spacing.xl)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                opacity = 1.0
                scale = 1.0
            }
        }
    }
}
```

### Phase 4: Day Complete & Streak Milestones (Week 2)

#### 4.1 Detect Day Complete

```swift
// In TaskListView
private func completeTask(_ task: TodoTask) {
    // ... existing code ...

    if isNowCompleted {
        // Check if all tasks are now complete
        let remainingTasks = todayTasks.filter { !$0.isCompletedToday }
        let isLastTask = remainingTasks.count == 1 && remainingTasks.first?.id == task.id

        if isLastTask {
            // Day complete celebration!
            celebrationMessage = "DAY CRUSHED! 🎉"
            // Trigger day complete share flow
        } else {
            celebrationMessage = EncouragingMessages.random()
        }
    }
}
```

#### 4.2 Detect Streak Milestones

```swift
// In TaskService or TaskListView
private func checkStreakMilestone(currentStreak: Int) -> Int? {
    let milestones = [7, 14, 21, 30, 50, 75, 100, 150, 200, 365]
    return milestones.first { $0 == currentStreak }
}
```

---

## File Structure

After implementation:

```
/dailytodolist/
├── Services/
│   ├── TaskService.swift (existing)
│   ├── ShareService.swift (NEW)
│   └── ImageRenderer+Extensions.swift (NEW)
│
├── Components/
│   ├── Share/ (NEW FOLDER)
│   │   ├── ShareCardView.swift
│   │   ├── TaskCompletionCard.swift
│   │   ├── DayCompleteCard.swift
│   │   ├── StreakMilestoneCard.swift
│   │   ├── SharePromptOverlay.swift
│   │   ├── PhotoPickerSheet.swift
│   │   └── CameraView.swift
│   │
│   └── ... (existing components)
│
├── Views/
│   ├── SharePreviewView.swift (NEW)
│   ├── TaskListView.swift (MODIFIED)
│   └── ... (existing views)
```

---

## Design Specifications

### Card Dimensions

| Platform | Dimensions | Ratio |
|----------|------------|-------|
| Instagram Story | 1080 x 1920 | 9:16 |
| TikTok | 1080 x 1920 | 9:16 |
| Instagram Post | 1080 x 1080 | 1:1 |
| Twitter/X | 1200 x 675 | 16:9 |

**Primary target**: 9:16 (Stories/TikTok) - Most viral potential

### Colors (from existing ColorPalette)

| Element | Color | Hex |
|---------|-------|-----|
| Card background | Brand Black | #0A0A0A |
| Text primary | Pure White | #FFFFFF |
| Text secondary | Medium Gray | #808080 |
| Accent/checkmark | Recovery Green | #2DD881 |
| Streak flame | Strain Red / Performance Orange | #FF4444 / #FF9500 |
| Divider | Dark Gray 2 | #2A2A2A |

### Typography

| Element | Style |
|---------|-------|
| Task name | Typography.headline (17pt, semibold) |
| Stats | Typography.subheadline (15pt, regular) |
| Date | Typography.caption (12pt, regular) |
| Logo | Typography.caption (12pt, bold) |

### Animations

| Animation | Spec |
|-----------|------|
| Share prompt appear | Spring: response 0.4, damping 0.7 |
| Card preview | Fade in: 0.3s ease |
| Success feedback | Haptic: .success |

---

## Privacy & Permissions

### Required Permissions

Add to `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Take a photo to share with your completed task</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Choose a photo to share with your completed task</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>Save your share cards to your photo library</string>
```

### Privacy Considerations

- Photos are processed locally only
- No photos uploaded to any server
- User controls what gets shared
- Skip option always available

---

## Success Metrics

| Metric | Target |
|--------|--------|
| Share prompt → photo added | 20%+ |
| Photo added → shared | 60%+ |
| Daily active users sharing | 5-10% |
| Shares per user per week | 2-3 |

---

## Timeline

| Phase | Duration | Deliverables |
|-------|----------|--------------|
| **Phase 1** | 3-4 days | ShareService, Card Views, Image Rendering |
| **Phase 2** | 2-3 days | Photo Picker, Camera Integration |
| **Phase 3** | 3-4 days | Share Flow, TaskListView Integration |
| **Phase 4** | 2-3 days | Day Complete, Streak Milestones |
| **Testing** | 2-3 days | Bug fixes, polish |

**Total: ~2 weeks**

---

## Future Enhancements

1. **Video export** - Animated card with celebration
2. **Custom backgrounds** - Choose from preset gradients
3. **Stickers/overlays** - Add emoji reactions
4. **Weekly recap** - Auto-generated weekly summary card
5. **Social feed** - In-app feed of friends' shares (major feature)

---

## Appendix: Encouraging Headlines for Cards

```swift
enum ShareHeadlines {
    static let taskComplete = [
        "CRUSHED IT",
        "DONE",
        "KNOCKED OUT",
        "HANDLED",
        "✓ COMPLETE"
    ]

    static let dayComplete = [
        "DAY CRUSHED",
        "ALL DONE",
        "PERFECT DAY",
        "100%",
        "UNSTOPPABLE"
    ]

    static let streakMilestone = [
        "ON FIRE",
        "UNSTOPPABLE",
        "CONSISTENCY KING",
        "LOCKED IN",
        "CAN'T BE STOPPED"
    ]
}
```
