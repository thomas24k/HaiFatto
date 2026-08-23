// Hai fatto? — Medium Widget
import WidgetKit
import SwiftUI

struct MediumWidgetEntry: TimelineEntry {
    let date: Date
    let tasks: [SharedTask]
}

struct MediumWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> MediumWidgetEntry {
        MediumWidgetEntry(date: Date(), tasks: [
            SharedTask(id: UUID(), name: "Read a book", icon: "book", colorHex: "#007AFF", isCompleted: false, lastCompletedAt: nil, sortOrder: 0),
            SharedTask(id: UUID(), name: "Exercise", icon: "figure.walk", colorHex: "#34C759", isCompleted: true, lastCompletedAt: nil, sortOrder: 1)
        ])
    }

    func getSnapshot(in context: Context, completion: @escaping (MediumWidgetEntry) -> ()) {
        let entry = MediumWidgetEntry(date: Date(), tasks: fetchTasks())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = MediumWidgetEntry(date: Date(), tasks: fetchTasks())
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
            return Array(allTasks.prefix(3))
        } catch {
            print("Error decoding tasks: \(error)")
            return []
        }
    }
}

struct MediumWidgetEntryView : View {
    var entry: MediumWidgetProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Hai fatto?")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                let completed = entry.tasks.filter { $0.isCompleted }.count
                let total = entry.tasks.count
                if total > 0 {
                    Text("\(completed)/\(total)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
            .padding(.bottom, 4)
            
            if entry.tasks.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    WidgetEmptyView()
                    Spacer()
                }
                Spacer()
            } else {
                VStack(spacing: 10) {
                    ForEach(entry.tasks) { task in
                        WidgetTaskRow(task: task)
                    }
                }
                Spacer(minLength: 0)
            }
        }
        .containerBackground(for: .widget) {
            Color(UIColor.systemBackground)
        }
    }
}

struct MediumWidget: Widget {
    let kind: String = "MediumWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MediumWidgetProvider()) { entry in
            MediumWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Hai fatto? - List")
        .description("Track up to 3 tasks")
        .supportedFamilies([.systemMedium])
    }
}
