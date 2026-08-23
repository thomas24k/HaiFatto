// Hai fatto? — Widget View Components
import SwiftUI
import AppIntents

struct WidgetTaskRow: View {
    let task: SharedTask
    
    var body: some View {
        Button(intent: ToggleTaskIntent(taskID: task.id.uuidString)) {
            HStack(spacing: 10) {
                Image(systemName: task.icon)
                    .font(.caption)
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
                    .background(Color(hex: task.colorHex).opacity(task.isCompleted ? 0.5 : 1.0))
                    .clipShape(Circle())
                
                Text(task.name)
                    .font(.subheadline)
                    .fontWeight(task.isCompleted ? .regular : .semibold)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                    .strikethrough(task.isCompleted)
                    .lineLimit(1)
                
                Spacer()
                
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(task.isCompleted ? Color(hex: task.colorHex) : .secondary.opacity(0.3))
            }
        }
        .buttonStyle(.plain)
    }
}

struct WidgetProgressRing: View {
    let completed: Int
    let total: Int
    let colors: [Color]
    
    var progress: Double {
        if total == 0 { return 0 }
        return Double(completed) / Double(total)
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.2), lineWidth: 6)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: colors.isEmpty ? [.blue, .purple] : colors),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            
            Text("\(completed)/\(total)")
                .font(.system(size: 10, weight: .bold))
        }
    }
}

struct WidgetEmptyView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "plus.circle.fill")
                .font(.largeTitle)
                .foregroundStyle(.blue)
            
            Text("Add a task")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
