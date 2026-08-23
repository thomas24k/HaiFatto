// Hai fatto? — Large Widget
import WidgetKit
import SwiftUI

struct LargeWidgetEntry: TimelineEntry {
    let date: Date
    let tasks: [SharedTask]
}

struct LargeWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> LargeWidgetEntry {
        LargeWidgetEntry(date: Date(), tasks: [
            SharedTask(id: UUID(), name: "Read a book", icon: "book", colorHex: "#007AFF", isCompleted: false, lastCompletedAt: nil, sortOrder: 0),
            SharedTask(id: UUID(), name: "Exercise", icon: "figure.walk", colorHex: "#34C759", isCompleted: true, lastCompletedAt: nil, sortOrder: 1)
        ])
    }

    func getSnapshot(in context: Context, completion: @escaping (LargeWidgetEntry) -> ()) {
        let entry = LargeWidgetEntry(date: Date(), tasks: fetchTasks())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = LargeWidgetEntry(date: Date(), tasks: fetchTasks())
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
            let allTasks = try JSONDecoder().decode([SharedTask].self, from: data).sorted(by: { $0.sortOrder < $1.sortOrder })
            return Array(allTasks.prefix(5))
        } catch {
            print("Error decoding tasks: \(error)")
            return []
        }
    }
}

struct LargeWidgetEntryView : View {
    var entry: LargeWidgetProvider.Entry

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Hai fatto?")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                let completed = entry.tasks.filter { $0.isCompleted }.count
                let total = entry.tasks.count
                
                if total > 0 {
                    WidgetProgressRing(
                        completed: completed,
                        total: total,
                        colors: entry.tasks.map { Color(hex: $0.colorHex) }
                    )
                    .frame(width: 40, height: 40)
                }
            }
            .padding(.bottom, 8)
            
            if entry.tasks.isEmpty {
                Spacer()
                WidgetEmptyView()
                Spacer()
            } else {
                VStack(spacing: 16) {
                    ForEach(entry.tasks) { task in
                        WidgetTaskRow(task: task)
                        if task.id != entry.tasks.last?.id {
                            Divider()
                        }
                    }
                }
                Spacer(minLength: 0)
                
                if entry.tasks.allSatisfy({ $0.isCompleted }) && !entry.tasks.isEmpty {
                    Text(String(localized: "All done for today! 🎉"))
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
            }
        }
        .containerBackground(for: .widget) {
            Color(UIColor.systemBackground)
        }
    }
}

struct LargeWidget: Widget {
    let kind: String = "LargeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LargeWidgetProvider()) { entry in
            LargeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Hai fatto? - Detailed")
        .description("Track up to 5 tasks and progress")
        .supportedFamilies([.systemLarge])
    }
}
