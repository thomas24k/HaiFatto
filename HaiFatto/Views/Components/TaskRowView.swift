// Hai fatto? — TaskRowView
import SwiftUI
import SwiftData

struct TaskRowView: View {
    @Bindable var task: HaiFattoTask
    var isPremium: Bool
    var onToggle: () -> Void
    var onEdit: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    
    private func relativeTimeString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Left: Circle with task color background containing SF Symbol icon
            ZStack {
                Circle()
                    .fill(task.color.opacity(task.isCompleted ? 0.6 : 1.0))
                    .frame(width: 44, height: 44)
                
                Image(systemName: task.icon)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .contentTransition(.symbolEffect(.replace))
                
                if task.requiresPhoto && !task.isCompleted {
                    Image(systemName: "camera.fill")
                        .font(.caption2)
                        .padding(4)
                        .background(Color(.systemBackground))
                        .clipShape(Circle())
                        .offset(x: 16, y: 16)
                }
            }
            .scaleEffect(task.isCompleted ? 0.9 : 1.0)
            
            // Center: VStack with task name and last completed
            VStack(alignment: .leading, spacing: 4) {
                Text(task.name)
                    .font(.headline)
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                
                if let lastCompletedAt = task.lastCompletedAt {
                    Text(String(localized: "Completed \(relativeTimeString(from: lastCompletedAt))"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text(String(localized: "Not completed yet"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // Right: Toggle button
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 28, height: 28)
                    .foregroundStyle(task.isCompleted ? task.color : .secondary.opacity(0.3))
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
        .opacity(task.isCompleted ? 0.8 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: task.isCompleted)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                onDelete?()
            } label: {
                Label(String(localized: "Delete"), systemImage: "trash")
            }
            .tint(.red)
            
            Button {
                onEdit?()
            } label: {
                Label(String(localized: "Edit"), systemImage: "pencil")
            }
            .tint(.blue)
        }
    }
}
