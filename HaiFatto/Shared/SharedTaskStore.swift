// Hai fatto? — Shared Task Store for Widget Communication
import Foundation
import WidgetKit

public struct SharedTask: Codable, Identifiable {
    public var id: UUID
    public var name: String
    public var icon: String
    public var colorHex: String
    public var isCompleted: Bool
    public var lastCompletedAt: Date?
    public var sortOrder: Int
}

public struct SharedTaskStore {
    public static func saveTasks(_ tasks: [HaiFattoTask]) {
        let sharedTasks = tasks.map { task in
            SharedTask(
                id: task.id,
                name: task.name,
                icon: task.icon,
                colorHex: task.colorHex,
                isCompleted: task.isCompleted,
                lastCompletedAt: task.lastCompletedAt,
                sortOrder: task.sortOrder
            )
        }
        
        if let encoded = try? JSONEncoder().encode(sharedTasks) {
            AppGroup.sharedUserDefaults?.set(encoded, forKey: AppGroup.tasksKey)
        }
    }
    
    public static func loadTasks() -> [SharedTask] {
        guard let data = AppGroup.sharedUserDefaults?.data(forKey: AppGroup.tasksKey),
              let tasks = try? JSONDecoder().decode([SharedTask].self, from: data) else {
            return []
        }
        return tasks.sorted { $0.sortOrder < $1.sortOrder }
    }
    
    public static func toggleTask(id: UUID) {
        var tasks = loadTasks()
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            tasks[index].isCompleted.toggle()
            if tasks[index].isCompleted {
                tasks[index].lastCompletedAt = .now
            }
            
            if let encoded = try? JSONEncoder().encode(tasks) {
                AppGroup.sharedUserDefaults?.set(encoded, forKey: AppGroup.tasksKey)
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
}
