//
//  ReorderableTaskList.swift
//  dailytodolist
//
//  Purpose: A reorderable task list component with drag-to-reorder support
//

import SwiftUI
import UniformTypeIdentifiers

/// A task list that supports drag-to-reorder for incomplete tasks
struct ReorderableTaskList: View {
    @Binding var tasks: [TodoTask]
    let onComplete: (TodoTask) -> Void
    let onDelete: (TodoTask) -> Void
    let onReorder: ([TodoTask]) -> Void
    var onEdit: ((TodoTask) -> Void)?

    @State private var draggingTask: TodoTask?

    var body: some View {
        VStack(spacing: Spacing.sm) {
            ForEach(tasks) { task in
                TaskRow(task: task, onComplete: { completedTask in
                    onComplete(completedTask)
                }, onEdit: { taskToEdit in
                    onEdit?(taskToEdit)
                })
                .contextMenu {
                    Button(role: .destructive) {
                        onDelete(task)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .onDrag {
                    // Only allow dragging incomplete tasks
                    if !task.isCompletedToday() {
                        self.draggingTask = task
                        return NSItemProvider(object: task.id.uuidString as NSString)
                    }
                    return NSItemProvider()
                } preview: {
                    TaskRow(task: task, onComplete: nil)
                        .frame(width: 350)
                }
                .onDrop(of: [.text], delegate: TaskDropDelegate(
                    task: task,
                    tasks: $tasks,
                    draggingTask: $draggingTask,
                    onReorder: onReorder
                ))
            }
        }
        .onChange(of: draggingTask) { oldValue, newValue in
            // Reset after a short delay if drag ends without proper drop
            if newValue != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    if draggingTask?.id == newValue?.id {
                        draggingTask = nil
                    }
                }
            }
        }
    }
}

/// Drop delegate for handling task reordering
struct TaskDropDelegate: DropDelegate {
    let task: TodoTask
    @Binding var tasks: [TodoTask]
    @Binding var draggingTask: TodoTask?
    let onReorder: ([TodoTask]) -> Void

    func performDrop(info: DropInfo) -> Bool {
        DispatchQueue.main.async {
            draggingTask = nil
        }
        return true
    }

    func dropEntered(info: DropInfo) {
        guard let draggingTask = draggingTask,
              draggingTask.id != task.id,
              !task.isCompletedToday(),  // Can't drop on completed tasks
              !draggingTask.isCompletedToday()  // Can't drag completed tasks
        else { return }

        guard let fromIndex = tasks.firstIndex(where: { $0.id == draggingTask.id }),
              let toIndex = tasks.firstIndex(where: { $0.id == task.id })
        else { return }

        if fromIndex != toIndex {
            withAnimation(.easeInOut(duration: 0.2)) {
                tasks.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
            }
            onReorder(tasks)
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func dropExited(info: DropInfo) {
        // Called when drag exits this drop target
    }

    func dropSessionDidEnd(info: DropInfo) {
        // Called when the entire drag session ends
        DispatchQueue.main.async {
            draggingTask = nil
        }
    }
}
