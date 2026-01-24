# Claude Code Implementation Guide

## Overview
This guide explains how to use **Claude Code** (Anthropic's AI coding assistant) to implement the Daily To-Do List app efficiently. Claude Code can help you write code, debug issues, and understand the architecture as you work through each phase.

---

## What is Claude Code?

Claude Code is an AI-powered development assistant that can:
- Write and edit code files
- Explain complex code concepts
- Debug errors and suggest fixes
- Refactor code for better quality
- Generate documentation
- Run terminal commands and tests

---

## Getting Started with Claude Code

### Prerequisites
- Claude Code CLI installed and configured
- Xcode installed (for iOS development)
- Basic familiarity with Swift and SwiftUI

### Project Setup
This project is already initialized with:
- Basic SwiftUI template
- Xcode project structure
- Git repository
- Implementation plan (`IMPLEMENTATION_PLAN.md`)

---

## How to Use Claude Code for Each Phase

### Phase 1: Foundation & Data Models

**Step 1: Ask Claude to create the Task model**
```
Create the Task.swift model file according to Phase 1 of IMPLEMENTATION_PLAN.md.
Include all properties, SwiftData annotations, and the isCompletedToday() helper method.
Add comprehensive documentation comments.
```

**Step 2: Ask Claude to create the TaskCompletion model**
```
Create the TaskCompletion.swift model file with SwiftData support.
Include the relationship to Task and add clear documentation.
```

**Step 3: Configure SwiftData**
```
Update dailytodolistApp.swift to configure the SwiftData ModelContainer
for Task and TaskCompletion models. Add comments explaining the setup.
```

**Step 4: Create basic views**
```
Create TaskListView.swift and HistoryView.swift with empty states.
Then create MainTabView.swift for tab navigation between these two screens.
```

**Testing**: Run in simulator and verify the app launches with two tabs.

---

### Phase 2: Add Tasks & Display Today's List

**Step 1: Create TaskService**
```
Create TaskService.swift with methods for:
- createTask()
- fetchActiveTasks()
- fetchTodayTasks()

Include comprehensive comments explaining the filtering logic for recurring
vs non-recurring tasks.
```

**Step 2: Create AddTaskSheet**
```
Create AddTaskSheet.swift with a form containing:
- Title text field
- Category picker
- Recurring toggle
Add validation and documentation.
```

**Step 3: Create TaskRow**
```
Create TaskRow.swift to display individual tasks with:
- Task title
- Category badge
- Recurring indicator (if applicable)
Document the component clearly.
```

**Step 4: Update TaskListView**
```
Update TaskListView.swift to:
- Display tasks using TaskRow
- Show "Add Task" button
- Present AddTaskSheet
- Implement swipe-to-delete
```

**Testing**: Add tasks in simulator and verify they appear and persist.

---

### Phase 3: Task Completion & Recurring Logic

**Step 1: Implement completion logic**
```
Update TaskService.swift to add:
- toggleTaskCompletion()
- completeTask()
- uncompleteTask()

Add detailed comments explaining how recurring tasks work differently
from non-recurring tasks.
```

**Step 2: Update TaskRow for completion**
```
Update TaskRow.swift to:
- Show checkbox
- Handle tap to toggle completion
- Update visual state (strikethrough, checkmark)
Add documentation for the completion state management.
```

**Step 3: Test recurring behavior**
```
Help me test the recurring task logic. I'll change my device date to tomorrow.
What should I verify to ensure recurring tasks work correctly?
```

**Testing**: Complete tasks and verify recurring tasks reappear next day.

---

### Phase 4: History View Implementation

**Step 1: Add history fetching**
```
Update TaskService.swift to add:
- fetchHistory(for:)
- fetchHistoryGroupedByDate()

Explain the date grouping logic clearly in comments.
```

**Step 2: Create HistoryRow**
```
Create HistoryRow.swift to display completed tasks with:
- Checkmark icon
- Task title and category
- Completion time
- Recurring badge if applicable
```

**Step 3: Update HistoryView**
```
Update HistoryView.swift to:
- Load history data grouped by date
- Display sections for each date
- Show HistoryRow for each completion
- Handle empty state
```

**Testing**: Complete tasks and verify they appear in history grouped by date.

---

### Phase 5: Drag-and-Drop Reordering & Polish

**Step 1: Implement reordering**
```
Update TaskService.swift to add:
- reorderTasks()

Update TaskListView.swift to add:
- .onMove() modifier
- EditButton for reordering mode

Document the sortOrder update logic.
```

**Step 2: Add polish**
```
Add the following polish features:
- Pull-to-refresh on both tabs
- Smooth animations for task completion
- Improved spacing and colors
- Better empty state messages
```

**Step 3: Final testing**
```
Help me create a comprehensive test plan to verify:
- All core functionality works
- Edge cases are handled
- UI is polished and responsive
```

**Testing**: Complete full testing checklist from IMPLEMENTATION_PLAN.md.

---

## Effective Prompts for Claude Code

### Writing New Code
```
Create [FileName.swift] for [purpose]. Include:
- [List specific requirements]
- Comprehensive documentation
- Error handling
- SwiftUI best practices
```

### Understanding Existing Code
```
Explain how [specific function/class] works in [FileName.swift].
Include details about why it's implemented this way.
```

### Debugging Issues
```
I'm getting this error: [paste error message]
The error occurs in [FileName.swift] at [function name].
Here's what I was trying to do: [describe action]
```

### Refactoring Code
```
Review [FileName.swift] and suggest improvements for:
- Code clarity
- Performance
- SwiftUI best practices
- Better documentation
```

### Adding Documentation
```
Add comprehensive documentation to all functions in [FileName.swift].
Include:
- Function purpose
- Parameter descriptions
- Return value explanation
- Usage examples if complex
```

---

## Tips for Working with Claude Code

### 1. Be Specific
❌ Bad: "Fix the task view"
✅ Good: "Update TaskRow.swift to show a checkmark icon when task.isCompletedToday() returns true"

### 2. Reference the Plan
```
Implement Phase 2, Step 1 from IMPLEMENTATION_PLAN.md.
Create TaskService.swift with the methods listed.
```

### 3. Ask for Explanations
```
Before implementing, explain the difference between the Task and TaskCompletion
models and why we need both for recurring tasks.
```

### 4. Request Documentation
```
Add detailed documentation to the toggleTaskCompletion() method explaining:
- What it does
- How it handles recurring vs non-recurring tasks
- What happens when called twice in the same day
```

### 5. Test Incrementally
```
I've completed Phase 2. Help me create a testing checklist to verify
everything works before moving to Phase 3.
```

### 6. Debug Together
```
The app crashes when I complete a recurring task. Here's the error:
[paste error]

Let's debug this step by step.
```

---

## Common Tasks & How to Ask Claude

### Creating a New File
```
Create Views/Components/DateHeaderView.swift that displays:
- The current date in a large, formatted style
- A count of today's tasks
Include @State and proper SwiftUI structure.
```

### Modifying Existing Code
```
Update TaskListView.swift to add a pull-to-refresh gesture.
When pulled, it should reload tasks from TaskService.
```

### Understanding Architecture
```
Explain the data flow in this app:
- How does a task get created?
- How does it appear in the UI?
- How does SwiftData keep the UI in sync?
```

### Fixing Bugs
```
When I mark a recurring task complete, it doesn't disappear from today's list.
Help me debug TaskService.fetchTodayTasks() and the completion logic.
```

### Optimizing Performance
```
Review TaskService.swift and suggest optimizations for:
- Database query efficiency
- Reducing unnecessary SwiftData fetches
- Better filtering logic
```

### Adding Features
```
Add a feature to edit existing tasks. Users should be able to:
- Tap on a task to open edit sheet
- Change title, category, and recurring status
- Save changes to SwiftData
```

---

## Project-Specific Guidelines

### SwiftData Best Practices
1. Always use `@Model` macro for data classes
2. Use `@Query` in views for automatic updates
3. Use `ModelContext` in service classes for manual operations
4. Remember to call `modelContext.save()` after changes

### Date Handling
1. Always use `Calendar.current.startOfDay(for:)` for date comparisons
2. Store dates in UTC, compare using Calendar
3. Don't compare Date objects directly (time component issues)

### Recurring Task Logic
1. Task never changes - it's a template
2. TaskCompletion records each instance of completion
3. `isCompletedToday()` checks if completion exists for today
4. Filtering in `fetchTodayTasks()` determines visibility

### Documentation Standards
Every function should have:
```swift
/// Brief one-line description
///
/// Detailed explanation including:
/// - How it works
/// - Why certain decisions were made
/// - Edge cases handled
///
/// - Parameters:
///   - param: Description
/// - Returns: Description
/// - Throws: Error conditions
```

---

## Debugging with Claude Code

### Common Issues & Solutions

**Issue: Tasks don't persist after app restart**
```
Ask Claude: "My tasks aren't persisting. Help me verify:
1. ModelContainer is configured correctly in dailytodolistApp.swift
2. modelContext.save() is called after creating tasks
3. SwiftData is not set to in-memory mode"
```

**Issue: Recurring tasks don't reappear**
```
Ask Claude: "Debug the recurring task logic. Walk through:
1. How fetchTodayTasks() filters recurring vs non-recurring
2. How isCompletedToday() checks completion
3. What happens when the date changes"
```

**Issue: History shows incorrect dates**
```
Ask Claude: "The history view shows wrong dates. Review:
1. How completedDate is set in TaskCompletion
2. How dates are grouped in fetchHistoryGroupedByDate()
3. Date comparison logic using Calendar"
```

**Issue: Drag-and-drop doesn't persist**
```
Ask Claude: "Reordering doesn't save. Check:
1. How sortOrder is updated in reorderTasks()
2. If modelContext.save() is called
3. If @Query is sorting by sortOrder"
```

---

## Code Review Checklist

Before moving to the next phase, ask Claude to review:

```
Review my Phase [X] implementation and verify:

✅ Code Quality
- [ ] All functions are documented
- [ ] No force unwraps (use guard/if let)
- [ ] Error handling is present
- [ ] SwiftUI best practices followed

✅ Functionality
- [ ] All Phase requirements completed
- [ ] Code compiles without warnings
- [ ] Features work in simulator
- [ ] Edge cases handled

✅ Architecture
- [ ] Service layer handles business logic
- [ ] Views only handle UI
- [ ] SwiftData used correctly
- [ ] No duplicate code

✅ Documentation
- [ ] File header comments present
- [ ] All public functions documented
- [ ] Complex logic has inline comments
- [ ] README updated if needed
```

---

## Advanced Usage

### Generating Unit Tests
```
Create unit tests for TaskService.swift. Include tests for:
- Creating tasks
- Completing tasks
- Filtering today's tasks
- Recurring task behavior over multiple days
```

### Performance Analysis
```
Analyze the performance of fetchHistoryGroupedByDate().
Suggest optimizations for:
- Large datasets (1000+ completions)
- Minimizing database queries
- Efficient grouping algorithm
```

### Accessibility Improvements
```
Review the app for accessibility and add:
- VoiceOver labels
- Dynamic Type support
- Proper contrast ratios
- Meaningful accessibility hints
```

### Dark Mode Support
```
Add proper dark mode support to:
- TaskRow colors
- Category badges
- History view
Ensure good contrast in both modes.
```

---

## Integration with Xcode

### Running the App
Claude Code can help you run commands:
```
Can you run "xcodebuild -scheme dailytodolist -sdk iphonesimulator"
to check if the project builds?
```

### Opening in Simulator
```
Help me open the iOS Simulator and run the app.
What commands do I need?
```

### Viewing Logs
```
The app crashed in the simulator. Can you help me:
1. Find the crash logs
2. Identify the error
3. Fix the issue
```

---

## Workflow Example: Implementing Phase 2

Here's a complete example of working with Claude Code on Phase 2:

**1. Start the phase**
```
I'm ready to start Phase 2. Let's begin by creating TaskService.swift.
Reference IMPLEMENTATION_PLAN.md for the requirements.
```

**2. Implement first file**
```
Create Services/TaskService.swift with:
- createTask(title:category:isRecurring:)
- fetchActiveTasks()
- fetchTodayTasks()

Include detailed comments explaining the filtering logic.
```

**3. Review and understand**
```
Explain how fetchTodayTasks() works and why recurring tasks
are filtered differently than non-recurring tasks.
```

**4. Continue with UI**
```
Now create Views/AddTaskSheet.swift with:
- Form with title TextField
- Category Picker (use: Personal, Work, Health, Shopping, Other)
- Recurring toggle with explanatory footer text
- Save and Cancel buttons
```

**5. Test**
```
I've run the app and I can see the add task button, but tapping it
doesn't show the sheet. Help me debug TaskListView.swift.
```

**6. Fix issue**
```
Update TaskListView.swift to properly present AddTaskSheet using
.sheet(isPresented:) modifier.
```

**7. Final review**
```
Review all Phase 2 code and verify:
- All files are properly documented
- Code follows Swift best practices
- No warnings or errors
- Features work in simulator
```

**8. Move to next phase**
```
Phase 2 is complete and tested. Let's move to Phase 3.
Create a quick summary of what we built in Phase 2.
```

---

## Resources

### Within This Project
- `IMPLEMENTATION_PLAN.md` - Complete implementation guide
- `README.md` - Project overview (if exists)
- Swift files in `/dailytodolist/` - Source code

### Ask Claude Code
```
What files exist in this project? Show me the structure.
```

```
Explain the overall architecture of this app based on the
existing code and IMPLEMENTATION_PLAN.md
```

```
What's the difference between @Query and manual ModelContext usage?
When should I use each?
```

---

## Best Practices Summary

1. **Read the plan first** - Always reference IMPLEMENTATION_PLAN.md
2. **Work phase by phase** - Don't skip ahead
3. **Test frequently** - Run in simulator after each file
4. **Document as you go** - Don't leave it for later
5. **Ask for explanations** - Understand, don't just copy code
6. **Review before proceeding** - Check each phase is complete
7. **Commit often** - Use git after each phase
8. **Debug systematically** - Work through errors step by step

---

## Getting Help

### When Stuck
```
I'm stuck on [specific issue]. Here's what I've tried:
1. [First attempt]
2. [Second attempt]

Here's the error: [paste error]
Can you help me troubleshoot?
```

### When Confused
```
I don't understand why we need [specific concept].
Can you explain it using a simple example?
```

### When Planning
```
Before I implement [feature], explain:
- How it fits in the architecture
- What files will be affected
- What edge cases to consider
```

---

## Conclusion

Claude Code is your development partner for this project. Use it to:
- Write better code faster
- Understand complex concepts
- Debug efficiently
- Learn iOS development best practices

Remember: **The goal is to learn**, not just to complete the project. Ask questions, understand the code, and use Claude Code as a teaching tool.

**Ready to start?** Begin with Phase 1 from `IMPLEMENTATION_PLAN.md`!

Good luck! 🚀
