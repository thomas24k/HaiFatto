// Hai fatto? — Small Widget
import WidgetKit
import SwiftUI

struct SmallWidgetEntry: TimelineEntry {
    let date: Date
    let task: SharedTask?
}

struct SmallWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> SmallWidgetEntry {
        SmallWidgetEntry(date: Date(), task: SharedTask(id: UUID(), name: "Sample Task", icon: "star", colorHex: "#34C759", isCompleted: false, lastCompletedAt: nil, sortOrder: 0))
    }

    func getSnapshot(in context: Context, completion: @escaping (SmallWidgetEntry) -> ()) {
        let entry = SmallWidgetEntry(date: Date(), task: fetchTasks().first)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = SmallWidgetEntry(date: Date(), task: fetchTasks().first)
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(15 * 60)))
        completion(timeline)
    }
    
    private func fetchTasks() -> [SharedTask] {
        let appGroupIdentifier = "group.com.haifatto.shared"
        let tasksKey = "shared_tasks"
        
        guard let defaults = UserDefaults(suiteName: appGroupIdentifier),
              let data = defaults.data(forKey: tasksKey) else {
            return []
        }
        
        do {
            return try JSONDecoder().decode([SharedTask].self, from: data).sorted(by: { $0.sortOrder < $1.sortOrder })
        } catch {
            print("Error decoding tasks: \(error)")
            return []
        }
    }
}

struct SmallWidgetEntryView : View {
    var entry: SmallWidgetProvider.Entry

    var body: some View {
        ZStack {
            if let task = entry.task {
                let taskColor = Color(hex: task.colorHex)
                
                VStack(spacing: 12) {
                    Image(systemName: task.icon)
                        .font(.largeTitle)
                        .foregroundColor(taskColor)
                        .frame(width: 50, height: 50)
                        .background(taskColor.opacity(0.2))
                        .clipShape(Circle())
                    
                    Text(task.name)
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    Button(intent: ToggleTaskIntent(taskID: task.id.uuidString)) {
                        Text(task.isCompleted ? String(localized: "Completed") : String(localized: "Mark Done"))
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(task.isCompleted ? Color.gray : taskColor)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .containerBackground(for: .widget) {
                    LinearGradient(
                        colors: [taskColor.opacity(0.1), taskColor.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            } else {
                WidgetEmptyView()
                    .containerBackground(for: .widget) {
                        Color(UIColor.systemBackground)
                    }
            }
        }
    }
}

struct SmallWidget: Widget {
    let kind: String = "SmallWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SmallWidgetProvider()) { entry in
            SmallWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Hai fatto? - Single")
        .description("Track a single task")
        .supportedFamilies([.systemSmall])
    }
}
