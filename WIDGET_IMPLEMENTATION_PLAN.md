# Today's Tasks Widget - Implementation Plan

## Overview

Create an iOS Home Screen widget that displays today's tasks with the same Whoop-inspired dark theme as the main app. Tapping the widget opens the app directly to the Tasks page.

---

## Widget Specifications

| Property | Value |
|----------|-------|
| **Widget Name** | Today's Tasks |
| **Supported Sizes** | Small, Medium, Large |
| **Deep Link** | Opens app to TaskListView |
| **Data Source** | SwiftData (shared container) |
| **Update Frequency** | Every 15 minutes + on task changes |

---

## Design System (Matching App)

### Colors
```swift
// Backgrounds
brandBlack     = #0A0A0A   // Widget background
darkGray1      = #1A1A1A   // Card backgrounds
darkGray2      = #2A2A2A   // Task row backgrounds

// Text
pureWhite      = #FFFFFF   // Primary text
mediumGray     = #808080   // Secondary text, labels

// Accents
recoveryGreen  = #2DD881   // Progress, completion
performancePurple = #7B61FF // Recurring badge

// Categories
workBlue       = #4A90E2
personalOrange = #F5A623
healthGreen    = #2DD881
shoppingMagenta = #BD10E0
```

### Typography
```swift
h4Size     = 17pt  // Task titles (medium weight)
labelSize  = 12pt  // Section labels (semibold, uppercase)
captionSize = 11pt // Badges (semibold)
```

### Spacing (4pt grid)
```swift
xs  = 4pt   // Badge padding vertical
sm  = 8pt   // Between elements
md  = 12pt  // Content padding
lg  = 16pt  // Section padding
```

### Corner Radius
```swift
standard = 12pt  // Task rows, cards
```

---

## Widget Layouts

### Small Widget (169x169 pt)
```
┌─────────────────────────┐
│  ☐ TODAY'S TASKS        │
│                         │
│     ┌─────────┐         │
│     │  3/5    │         │
│     │ ━━━━━━  │         │
│     └─────────┘         │
│                         │
│   60% complete          │
└─────────────────────────┘

Background: brandBlack (#0A0A0A)
Progress ring: recoveryGreen (#2DD881)
Text: pureWhite (#FFFFFF)
Label: mediumGray (#808080)
```

**Content:**
- Header label "TODAY'S TASKS"
- Circular progress indicator
- Fraction text (completed/total)
- Percentage text below

### Medium Widget (360x169 pt)
```
┌─────────────────────────────────────────────────┐
│  ☐ TODAY'S TASKS                    3/5  60%   │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━░░░░░░░░░░░░░   │
├─────────────────────────────────────────────────┤
│  ○  Morning workout              HEALTH         │
│  ○  Review PRs                   WORK   ↻DAILY  │
│  ○  Buy groceries                SHOPPING       │
└─────────────────────────────────────────────────┘

Background: brandBlack (#0A0A0A)
Progress bar: recoveryGreen (#2DD881)
Task rows: darkGray2 (#2A2A2A) - subtle or transparent
Category badges: respective category colors
Recurring badge: performancePurple (#7B61FF)
```

**Content:**
- Header with progress stats
- Linear progress bar
- 3 task rows with:
  - Circle checkbox (empty, decorative)
  - Task title
  - Category badge (pill shape)
  - Recurring badge if applicable

### Large Widget (360x376 pt)
```
┌─────────────────────────────────────────────────┐
│  ☐ TODAY'S TASKS                                │
│                                                 │
│  ┌───────────────────────────────────────────┐  │
│  │  DAILY PROGRESS                           │  │
│  │  3/5 completed                      60%   │  │
│  │  ━━━━━━━━━━━━━━━━━━━━░░░░░░░░░░░░░░░░░   │  │
│  └───────────────────────────────────────────┘  │
│                                                 │
│  ┌───────────────────────────────────────────┐  │
│  │  ○  Morning workout           HEALTH      │  │
│  └───────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────┐  │
│  │  ○  Review PRs            WORK  ↻ DAILY   │  │
│  └───────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────┐  │
│  │  ○  Team standup          WORK  ↻ DAILY   │  │
│  └───────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────┐  │
│  │  ○  Buy groceries             SHOPPING    │  │
│  └───────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────┐  │
│  │  ○  Call mom                  PERSONAL    │  │
│  └───────────────────────────────────────────┘  │
│                                                 │
│              + 2 more tasks                     │
└─────────────────────────────────────────────────┘

Background: brandBlack (#0A0A0A)
Progress card: darkGray1 (#1A1A1A) background
Task rows: darkGray2 (#2A2A2A) background
```

**Content:**
- Header "TODAY'S TASKS"
- DailyProgressCard (matching app design)
- 5 task rows with full styling
- "+N more tasks" footer if overflow

---

## Implementation Phases

### Phase 1: Project Setup & App Groups

**Files to modify:**
- `dailytodolist.xcodeproj` - Add Widget Extension target
- `dailytodolist.entitlements` - Add App Group capability
- `TodayTasksWidgetExtension.entitlements` - Add same App Group

**Steps:**
1. In Xcode: File → New → Target → Widget Extension
   - Product Name: `TodayTasksWidget`
   - Uncheck "Include Configuration App Intent" (for now)
   - Uncheck "Include Live Activity"

2. Add App Group capability to BOTH targets:
   - Select main app target → Signing & Capabilities → + Capability → App Groups
   - Add group: `group.com.dailytodolist.shared`
   - Repeat for widget target

3. Create shared entitlements file

**Deliverables:**
- [ ] Widget Extension target created
- [ ] App Group configured on both targets
- [ ] Project builds successfully

---

### Phase 2: Shared Data Layer

**New files to create:**

#### `Shared/SharedModelContainer.swift`
```swift
import SwiftData
import Foundation

enum SharedModelContainer {
    static let appGroupIdentifier = "group.com.dailytodolist.shared"

    static var sharedModelContainer: ModelContainer = {
        let schema = Schema([TodoTask.self, TaskCompletion.self])

        let storeURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)!
            .appendingPathComponent("dailytodolist.sqlite")

        let configuration = ModelConfiguration(
            schema: schema,
            url: storeURL,
            cloudKitDatabase: .none
        )

        return try! ModelContainer(for: schema, configurations: [configuration])
    }()
}
```

#### `Shared/WidgetDataService.swift`
```swift
import SwiftData
import Foundation

@MainActor
class WidgetDataService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchTodayTasks() -> [TodoTask] {
        let descriptor = FetchDescriptor<TodoTask>(
            predicate: #Predicate { $0.isActive },
            sortBy: [SortDescriptor(\.sortOrder)]
        )

        let allTasks = (try? modelContext.fetch(descriptor)) ?? []
        let today = Calendar.current.startOfDay(for: Date())

        return allTasks.filter { task in
            if task.isRecurring {
                return !task.isCompletedToday()
            } else {
                let hasCompletions = !(task.completions?.isEmpty ?? true)
                return !hasCompletions
            }
        }
    }

    func fetchTodayStats() -> (completed: Int, total: Int) {
        let tasks = fetchTodayTasks()
        let completedToday = fetchCompletedTodayCount()
        return (completedToday, tasks.count + completedToday)
    }

    func fetchCompletedTodayCount() -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        let descriptor = FetchDescriptor<TaskCompletion>(
            predicate: #Predicate { $0.completedAt >= today && $0.completedAt < tomorrow }
        )

        return (try? modelContext.fetchCount(descriptor)) ?? 0
    }
}
```

**Files to move/update:**
- Move `Models/TodoTask.swift` to `Shared/Models/` (accessible by both targets)
- Move `Models/TaskCompletion.swift` to `Shared/Models/`
- Update main app's `dailytodolistApp.swift` to use `SharedModelContainer`

**Deliverables:**
- [ ] Shared folder structure created
- [ ] SharedModelContainer configured with App Group URL
- [ ] WidgetDataService implemented
- [ ] Models accessible to both targets
- [ ] Main app uses shared container (verify existing data migrates)

---

### Phase 3: Widget Core Implementation

**New files to create in `TodayTasksWidget/`:**

#### `TodayTasksWidget.swift` (Main entry)
```swift
import WidgetKit
import SwiftUI

@main
struct TodayTasksWidgetBundle: WidgetBundle {
    var body: some Widget {
        TodayTasksWidget()
    }
}

struct TodayTasksWidget: Widget {
    let kind: String = "TodayTasksWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodayTasksProvider()) { entry in
            TodayTasksEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Today's Tasks")
        .description("View your tasks for today at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
```

#### `TodayTasksProvider.swift` (Timeline)
```swift
import WidgetKit
import SwiftData

struct TaskEntry: TimelineEntry {
    let date: Date
    let tasks: [WidgetTask]
    let completedCount: Int
    let totalCount: Int
}

struct WidgetTask: Identifiable {
    let id: UUID
    let title: String
    let category: String?
    let isRecurring: Bool
}

struct TodayTasksProvider: TimelineProvider {

    func placeholder(in context: Context) -> TaskEntry {
        TaskEntry(
            date: Date(),
            tasks: [
                WidgetTask(id: UUID(), title: "Morning workout", category: "Health", isRecurring: true),
                WidgetTask(id: UUID(), title: "Review PRs", category: "Work", isRecurring: false),
                WidgetTask(id: UUID(), title: "Buy groceries", category: "Shopping", isRecurring: false)
            ],
            completedCount: 2,
            totalCount: 5
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (TaskEntry) -> Void) {
        let entry = fetchEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TaskEntry>) -> Void) {
        let entry = fetchEntry()

        // Refresh at midnight and every 15 minutes
        let midnight = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
        let nextUpdate = min(
            midnight,
            Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        )

        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    @MainActor
    private func fetchEntry() -> TaskEntry {
        let container = SharedModelContainer.sharedModelContainer
        let service = WidgetDataService(modelContext: container.mainContext)

        let tasks = service.fetchTodayTasks()
        let stats = service.fetchTodayStats()

        let widgetTasks = tasks.map { task in
            WidgetTask(
                id: task.id,
                title: task.title,
                category: task.category,
                isRecurring: task.isRecurring
            )
        }

        return TaskEntry(
            date: Date(),
            tasks: widgetTasks,
            completedCount: stats.completed,
            totalCount: stats.total
        )
    }
}
```

#### `TodayTasksEntryView.swift` (Main view router)
```swift
import SwiftUI
import WidgetKit

struct TodayTasksEntryView: View {
    var entry: TaskEntry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}
```

**Deliverables:**
- [ ] Widget bundle and configuration
- [ ] TimelineProvider with data fetching
- [ ] Entry view routing by widget size
- [ ] Widget appears in widget gallery

---

### Phase 4: Widget Views (Matching App Design)

**New files:**

#### `Views/WidgetColors.swift` (Shared colors for widget)
```swift
import SwiftUI

extension Color {
    // Replicate from app (widgets can't access app target)
    static let widgetBrandBlack = Color(hex: "0A0A0A")
    static let widgetPureWhite = Color(hex: "FFFFFF")
    static let widgetRecoveryGreen = Color(hex: "2DD881")
    static let widgetPerformancePurple = Color(hex: "7B61FF")
    static let widgetDarkGray1 = Color(hex: "1A1A1A")
    static let widgetDarkGray2 = Color(hex: "2A2A2A")
    static let widgetMediumGray = Color(hex: "808080")

    // Categories
    static let widgetWorkBlue = Color(hex: "4A90E2")
    static let widgetPersonalOrange = Color(hex: "F5A623")
    static let widgetHealthGreen = Color(hex: "2DD881")
    static let widgetShoppingMagenta = Color(hex: "BD10E0")

    static func widgetCategoryColor(for category: String?) -> Color {
        guard let category = category else { return .widgetMediumGray }
        switch category.lowercased() {
        case "work": return .widgetWorkBlue
        case "personal": return .widgetPersonalOrange
        case "health": return .widgetHealthGreen
        case "shopping": return .widgetShoppingMagenta
        default: return .widgetMediumGray
        }
    }

    // Hex initializer (copy from app)
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
```

#### `Views/SmallWidgetView.swift`
```swift
import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    let entry: TaskEntry

    private var percentage: Double {
        guard entry.totalCount > 0 else { return 0 }
        return Double(entry.completedCount) / Double(entry.totalCount)
    }

    var body: some View {
        VStack(spacing: 8) {
            // Header
            HStack {
                Image(systemName: "checkmark.square")
                    .font(.system(size: 12, weight: .semibold))
                Text("TODAY'S TASKS")
                    .font(.system(size: 11, weight: .semibold))
                Spacer()
            }
            .foregroundStyle(Color.widgetMediumGray)

            Spacer()

            // Circular progress
            ZStack {
                Circle()
                    .stroke(Color.widgetDarkGray2, lineWidth: 8)

                Circle()
                    .trim(from: 0, to: percentage)
                    .stroke(Color.widgetRecoveryGreen, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: percentage)

                VStack(spacing: 2) {
                    Text("\(entry.completedCount)/\(entry.totalCount)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.widgetPureWhite)
                }
            }
            .frame(width: 80, height: 80)

            Spacer()

            // Percentage
            Text("\(Int(percentage * 100))% complete")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.widgetRecoveryGreen)
        }
        .padding(12)
        .background(Color.widgetBrandBlack)
        .widgetURL(URL(string: "dailytodolist://tasks"))
    }
}
```

#### `Views/MediumWidgetView.swift`
```swift
import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
    let entry: TaskEntry

    private var percentage: Double {
        guard entry.totalCount > 0 else { return 0 }
        return Double(entry.completedCount) / Double(entry.totalCount)
    }

    private var displayTasks: [WidgetTask] {
        Array(entry.tasks.prefix(3))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header row
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.square")
                        .font(.system(size: 12, weight: .semibold))
                    Text("TODAY'S TASKS")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundStyle(Color.widgetMediumGray)

                Spacer()

                Text("\(entry.completedCount)/\(entry.totalCount)")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.widgetPureWhite)

                Text("\(Int(percentage * 100))%")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.widgetRecoveryGreen)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.widgetDarkGray2)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.widgetRecoveryGreen)
                        .frame(width: geometry.size.width * percentage)
                }
            }
            .frame(height: 6)

            // Task list
            if displayTasks.isEmpty {
                HStack {
                    Spacer()
                    Text("All done for today!")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.widgetMediumGray)
                    Spacer()
                }
                .padding(.top, 8)
            } else {
                VStack(spacing: 6) {
                    ForEach(displayTasks) { task in
                        WidgetTaskRow(task: task, compact: true)
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color.widgetBrandBlack)
        .widgetURL(URL(string: "dailytodolist://tasks"))
    }
}
```

#### `Views/LargeWidgetView.swift`
```swift
import SwiftUI
import WidgetKit

struct LargeWidgetView: View {
    let entry: TaskEntry

    private var percentage: Double {
        guard entry.totalCount > 0 else { return 0 }
        return Double(entry.completedCount) / Double(entry.totalCount)
    }

    private var displayTasks: [WidgetTask] {
        Array(entry.tasks.prefix(5))
    }

    private var remainingCount: Int {
        max(0, entry.tasks.count - 5)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 4) {
                Image(systemName: "checkmark.square")
                    .font(.system(size: 14, weight: .semibold))
                Text("TODAY'S TASKS")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundStyle(Color.widgetMediumGray)

            // Progress card
            VStack(alignment: .leading, spacing: 8) {
                Text("DAILY PROGRESS")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.widgetMediumGray)

                HStack {
                    Text("\(entry.completedCount)/\(entry.totalCount) completed")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.widgetPureWhite)

                    Spacer()

                    Text("\(Int(percentage * 100))%")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.widgetRecoveryGreen)
                }

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.widgetDarkGray2)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.widgetRecoveryGreen)
                            .frame(width: geometry.size.width * percentage)
                    }
                }
                .frame(height: 8)
            }
            .padding(12)
            .background(Color.widgetDarkGray1)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Task list
            if displayTasks.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.widgetRecoveryGreen)
                        Text("All done for today!")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color.widgetMediumGray)
                    }
                    Spacer()
                }
                Spacer()
            } else {
                VStack(spacing: 8) {
                    ForEach(displayTasks) { task in
                        WidgetTaskRow(task: task, compact: false)
                    }
                }

                if remainingCount > 0 {
                    Text("+ \(remainingCount) more task\(remainingCount == 1 ? "" : "s")")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.widgetMediumGray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 4)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(Color.widgetBrandBlack)
        .widgetURL(URL(string: "dailytodolist://tasks"))
    }
}
```

#### `Views/WidgetTaskRow.swift`
```swift
import SwiftUI

struct WidgetTaskRow: View {
    let task: WidgetTask
    let compact: Bool

    var body: some View {
        HStack(spacing: 10) {
            // Empty checkbox circle
            Circle()
                .stroke(Color.widgetMediumGray, lineWidth: 2)
                .frame(width: compact ? 18 : 22, height: compact ? 18 : 22)

            // Task title
            Text(task.title)
                .font(.system(size: compact ? 14 : 16, weight: .medium))
                .foregroundStyle(Color.widgetPureWhite)
                .lineLimit(1)

            Spacer()

            // Badges
            HStack(spacing: 4) {
                if let category = task.category, !category.isEmpty {
                    WidgetCategoryBadge(category: category, compact: compact)
                }

                if task.isRecurring {
                    WidgetRecurringBadge(compact: compact)
                }
            }
        }
        .padding(.horizontal, compact ? 10 : 12)
        .padding(.vertical, compact ? 8 : 10)
        .background(Color.widgetDarkGray2)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct WidgetCategoryBadge: View {
    let category: String
    let compact: Bool

    var body: some View {
        Text(category.uppercased())
            .font(.system(size: compact ? 9 : 10, weight: .semibold))
            .foregroundStyle(Color.widgetCategoryColor(for: category))
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Color.widgetCategoryColor(for: category).opacity(0.2))
            .clipShape(Capsule())
    }
}

struct WidgetRecurringBadge: View {
    let compact: Bool

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "repeat")
                .font(.system(size: compact ? 8 : 9, weight: .bold))
            if !compact {
                Text("DAILY")
                    .font(.system(size: 9, weight: .semibold))
            }
        }
        .foregroundStyle(Color.widgetPerformancePurple)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Color.widgetPerformancePurple.opacity(0.15))
        .clipShape(Capsule())
    }
}
```

**Deliverables:**
- [ ] SmallWidgetView with circular progress
- [ ] MediumWidgetView with progress bar + 3 tasks
- [ ] LargeWidgetView with full progress card + 5 tasks
- [ ] WidgetTaskRow matching app's TaskRow design
- [ ] Category and recurring badges matching app
- [ ] All views use exact app color palette

---

### Phase 5: Deep Linking (Open to Tasks Page)

**Files to modify:**

#### Update `dailytodolistApp.swift`
```swift
import SwiftUI
import SwiftData

@main
struct dailytodolistApp: App {
    let sharedModelContainer = SharedModelContainer.sharedModelContainer

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
        .modelContainer(sharedModelContainer)
    }

    private func handleDeepLink(_ url: URL) {
        // URL: dailytodolist://tasks
        guard url.scheme == "dailytodolist" else { return }

        switch url.host {
        case "tasks":
            // Navigate to tasks tab
            NotificationCenter.default.post(
                name: .navigateToTasks,
                object: nil
            )
        default:
            break
        }
    }
}

extension Notification.Name {
    static let navigateToTasks = Notification.Name("navigateToTasks")
}
```

#### Update `MainTabView.swift`
```swift
// Add to MainTabView:

@State private var selectedTab: Tab = .today

var body: some View {
    // ... existing code ...
    .onReceive(NotificationCenter.default.publisher(for: .navigateToTasks)) { _ in
        selectedTab = .today
    }
}
```

#### Add URL Scheme to `Info.plist`
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>dailytodolist</string>
        </array>
        <key>CFBundleURLName</key>
        <string>com.dailytodolist</string>
    </dict>
</array>
```

**Deliverables:**
- [ ] URL scheme registered in Info.plist
- [ ] Deep link handler in app entry point
- [ ] MainTabView responds to navigation notification
- [ ] Tapping widget opens app to Tasks tab

---

### Phase 6: Widget Refresh Integration

**Files to modify:**

#### Update `TaskService.swift`
```swift
import WidgetKit

// Add after any task modification (create, complete, delete):

private func refreshWidgets() {
    WidgetCenter.shared.reloadAllTimelines()
}

// Call in these methods:
func createTask(...) {
    // existing code
    refreshWidgets()
}

func toggleTaskCompletion(...) {
    // existing code
    refreshWidgets()
}

func deleteTask(...) {
    // existing code
    refreshWidgets()
}

func softDeleteTask(...) {
    // existing code
    refreshWidgets()
}
```

**Deliverables:**
- [ ] Widget refreshes when tasks are created
- [ ] Widget refreshes when tasks are completed/uncompleted
- [ ] Widget refreshes when tasks are deleted
- [ ] Widget auto-refreshes at midnight (new day)

---

## File Summary

### New Files to Create
```
Shared/
├── SharedModelContainer.swift
└── WidgetDataService.swift

TodayTasksWidget/
├── TodayTasksWidget.swift
├── TodayTasksProvider.swift
├── TodayTasksEntryView.swift
└── Views/
    ├── WidgetColors.swift
    ├── SmallWidgetView.swift
    ├── MediumWidgetView.swift
    ├── LargeWidgetView.swift
    └── WidgetTaskRow.swift
```

### Files to Modify
```
dailytodolist/
├── dailytodolistApp.swift     (use shared container, add deep link)
├── Views/MainTabView.swift    (handle navigation notification)
├── Services/TaskService.swift (add widget refresh calls)
└── Info.plist                 (add URL scheme)

Project:
├── dailytodolist.xcodeproj    (add widget target, app groups)
└── *.entitlements             (app group configuration)
```

### Files to Move
```
Models/TodoTask.swift       → Shared/Models/TodoTask.swift
Models/TaskCompletion.swift → Shared/Models/TaskCompletion.swift
```

---

## Testing Checklist

- [ ] Widget appears in widget gallery
- [ ] Small widget shows correct progress
- [ ] Medium widget shows 3 tasks with badges
- [ ] Large widget shows progress card + 5 tasks
- [ ] Tapping any widget opens app to Tasks page
- [ ] Creating a task in app updates widget
- [ ] Completing a task updates widget
- [ ] Widget shows correct data after app restart
- [ ] Widget updates at midnight (new day)
- [ ] Empty state displays correctly when no tasks
- [ ] Category colors match app exactly
- [ ] Recurring badge matches app design

---

## Timeline Estimate

| Phase | Description |
|-------|-------------|
| Phase 1 | Project Setup & App Groups |
| Phase 2 | Shared Data Layer |
| Phase 3 | Widget Core Implementation |
| Phase 4 | Widget Views (Design Match) |
| Phase 5 | Deep Linking |
| Phase 6 | Widget Refresh Integration |

---

## Notes

1. **Data Migration**: When switching to shared container, existing user data needs to be migrated. Consider adding a one-time migration on first launch.

2. **Widget Limitations**:
   - No interactive checkboxes (would need AppIntents for iOS 17+)
   - Limited refresh frequency (system controlled)
   - 30MB memory limit

3. **Future Enhancements**:
   - Interactive widgets with task completion (iOS 17+)
   - Lock screen widgets
   - Widget configuration (filter by category)
   - Streak widget variant
