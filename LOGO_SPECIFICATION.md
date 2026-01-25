# Logo Specification: "Progress Ring"

## Overview

The Daily To-Do List app logo features a **circular progress ring** with a **centered checkmark**, representing daily task completion progress. The design aligns with the app's Whoop-inspired athletic performance aesthetic.

---

## Logo Concept

```
      ╭──────────╮
    ╱   ◐◓◓◓◓◓◓   ╲
   │      ╲╱       │
   │       ✓       │
   │               │
    ╲             ╱
      ╰──────────╯

       DAILY
```

**Key Elements:**
1. **Progress Ring** - Gradient arc showing ~75% completion (purple to green)
2. **Ring Track** - Subtle dark background track for the ring
3. **Checkmark** - Bold white checkmark centered in the ring
4. **Background** - Deep black with subtle radial gradient

---

## Color Palette

| Element | Color | Hex Code |
|---------|-------|----------|
| Ring Start | Performance Purple | `#7B61FF` |
| Ring Middle | Teal Accent | `#4ECDC4` |
| Ring End | Recovery Green | `#2DD881` |
| Ring Track | Dark Gray 2 | `#2A2A2A` |
| Checkmark | Pure White | `#FFFFFF` |
| Background | Brand Black | `#0A0A0A` |
| Background Center | Dark Gray 1 | `#1A1A1A` |

---

## Dimensions & Proportions

Based on 1024×1024 base size:

| Element | Value | Ratio |
|---------|-------|-------|
| Canvas | 1024×1024 | 100% |
| Ring Radius | 340px | 33.2% |
| Ring Stroke Width | 64px | 6.25% |
| Checkmark Stroke | 56px | 5.5% |
| Ring Progress | 75% | ~270° arc |
| Glow Radius | 12px | 1.2% |

### Checkmark Coordinates (1024×1024)
- Start point: (380, 520)
- Mid point: (470, 610)
- End point: (644, 420)

---

## Logo Variants

### 1. Primary Logo (Light & Standard)
- Full gradient ring on dark background
- Use for: App icon, marketing materials, splash screens
- File: `AppIcon.svg` → `AppIcon-1024.png`

### 2. Dark Mode Logo
- Enhanced contrast with pure black background
- Intensified glow effect
- Use for: iOS dark mode app icon
- File: `AppIcon-Dark.svg` → `AppIcon-Dark-1024.png`

### 3. Tinted/Monochrome Logo
- White ring and checkmark on black
- System applies tint color
- Use for: iOS tinted appearance, monochrome contexts
- File: `AppIcon-Tinted.svg` → `AppIcon-Tinted-1024.png`

### 4. Compact Logo
- Simplified version for small sizes (< 32pt)
- Thinner strokes, no glow
- Use for: Tab bars, navigation, favicons

### 5. Logo with Wordmark
- Progress ring + "DAILY" text below
- Font: SF Pro Display Black, tracking +5%
- Use for: Splash screens, about pages, marketing

---

## iOS App Icon Requirements

Export PNG files at **1024×1024** for each variant:

```
AppIcon.appiconset/
├── AppIcon-1024.png        (Standard)
├── AppIcon-Dark-1024.png   (Dark mode)
├── AppIcon-Tinted-1024.png (Tinted)
├── AppIcon.svg             (Source)
├── AppIcon-Dark.svg        (Source)
├── AppIcon-Tinted.svg      (Source)
└── Contents.json           (Manifest)
```

iOS automatically scales from 1024×1024 to required sizes.

---

## Exporting PNG Files

### Option 1: Using Inkscape (CLI)
```bash
# Install Inkscape if needed
# brew install inkscape

# Export at 1024x1024
inkscape AppIcon.svg --export-type=png --export-filename=AppIcon-1024.png --export-width=1024
inkscape AppIcon-Dark.svg --export-type=png --export-filename=AppIcon-Dark-1024.png --export-width=1024
inkscape AppIcon-Tinted.svg --export-type=png --export-filename=AppIcon-Tinted-1024.png --export-width=1024
```

### Option 2: Using ImageMagick
```bash
# Install ImageMagick if needed
# brew install imagemagick

convert -background none -size 1024x1024 AppIcon.svg AppIcon-1024.png
```

### Option 3: Using Figma/Sketch
1. Import SVG files
2. Export as PNG at 1024×1024
3. Ensure "Export for iOS" is selected

### Option 4: Online Converters
- [CloudConvert](https://cloudconvert.com/svg-to-png)
- [SVG to PNG](https://svgtopng.com/)

---

## SwiftUI Component

A programmatic version is available at:
```
dailytodolist/Components/AppLogo.swift
```

### Usage Examples

```swift
// Standard logo
AppLogo(size: 200)

// Animated logo (ring draws in)
AppLogo(size: 200, animated: true)

// Custom progress
AppLogo(size: 100, progress: 0.5)

// Compact version for small spaces
AppLogoCompact(size: 28)

// With wordmark
AppLogoWithWordmark(logoSize: 120)
```

### Exporting from SwiftUI
To export the logo from the SwiftUI component:

```swift
import SwiftUI

@MainActor
func exportLogo() {
    let logo = AppLogo(size: 1024, showBackground: true)
    let renderer = ImageRenderer(content: logo)
    renderer.scale = 1.0

    if let image = renderer.uiImage {
        if let data = image.pngData() {
            // Save to file or use as needed
        }
    }
}
```

---

## Design Rationale

### Why Progress Ring?

1. **Familiar Metaphor** - Similar to Apple's Activity rings, instantly recognizable
2. **Dynamic Representation** - Visually represents daily completion progress
3. **Whoop Alignment** - Matches the athletic/performance tracker aesthetic
4. **Scalability** - Works well from 20pt to 1024pt
5. **Animation Potential** - Ring can animate to show real-time progress

### Why This Color Gradient?

- **Purple (#7B61FF)** - Represents the starting point, premium feel
- **Teal (#4ECDC4)** - Transition color, adds depth
- **Green (#2DD881)** - Recovery/completion color from the design system

The gradient creates visual movement, guiding the eye along the progress path.

### Why 75% Progress?

The static logo shows ~75% completion because:
- Demonstrates the progress concept clearly
- Leaves visual "room to grow" (motivational)
- Creates an appealing asymmetric composition
- Avoids the static feeling of 100% or 50%

---

## Accessibility

### Color Contrast
- Checkmark: White on dark = 15.6:1 (exceeds AAA)
- Ring on background = 4.8:1+ (exceeds AA)

### Recognizability
- Checkmark is universally recognized
- Ring shape clear even without color

### Tinted Version
- Monochrome version for system tinting
- Works with any iOS tint color

---

## File Locations

```
/home/user/IOS-To-Do-List/
├── LOGO_SPECIFICATION.md          (This document)
├── dailytodolist/
│   ├── Assets.xcassets/
│   │   └── AppIcon.appiconset/
│   │       ├── Contents.json
│   │       ├── AppIcon.svg
│   │       ├── AppIcon-Dark.svg
│   │       └── AppIcon-Tinted.svg
│   └── Components/
│       └── AppLogo.swift          (SwiftUI component)
```

---

## Next Steps

1. **Export PNGs** - Convert SVG files to 1024×1024 PNG using preferred method
2. **Add to Xcode** - Place PNG files in AppIcon.appiconset folder
3. **Test on Device** - Verify appearance on home screen, dark mode, etc.
4. **Marketing Assets** - Create App Store screenshots with logo
