// Hai fatto? — Toggle Task AppIntent for interactive widgets
import AppIntents
import WidgetKit
import SwiftUI

struct SharedTask: Codable, Identifiable {
    var id: UUID
    var name: String
    var icon: String
    var colorHex: String
    var isCompleted: Bool
    var lastCompletedAt: Date?
    var sortOrder: Int
}

extension Color {
    init(hex: String) {
        var cleanHexCode = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        cleanHexCode = cleanHexCode.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        
        Scanner(string: cleanHexCode).scanHexInt64(&rgb)
        
        let redValue = Double((rgb >> 16) & 0xFF) / 255.0
        let greenValue = Double((rgb >> 8) & 0xFF) / 255.0
        let blueValue = Double(rgb & 0xFF) / 255.0
        
        self.init(red: redValue, green: greenValue, blue: blueValue)
    }
}

struct ToggleTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Task"
    static var description = IntentDescription("Toggles a task's completion status")
    
    @Parameter(title: "Task ID")
    var taskID: String
    
    init() {}
    init(taskID: String) { self.taskID = taskID }
    
    func perform() async throws -> some IntentResult {
        let appGroupIdentifier = "group.com.haifatto.shared"
        let tasksKey = "shared_tasks"
        
        guard let defaults = UserDefaults(suiteName: appGroupIdentifier) else {
            return .result()
        }
        
        if let data = defaults.data(forKey: tasksKey) {
            do {
                var tasks = try JSONDecoder().decode([SharedTask].self, from: data)
                if let index = tasks.firstIndex(where: { $0.id.uuidString == taskID }) {
                    tasks[index].isCompleted.toggle()
                    if tasks[index].isCompleted {
                        tasks[index].lastCompletedAt = Date()
                    }
                    
                    let encodedData = try JSONEncoder().encode(tasks)
                    defaults.set(encodedData, forKey: tasksKey)
                    WidgetCenter.shared.reloadAllTimelines()
                }
            } catch {
                print("Failed to decode/encode tasks: \(error)")
            }
        }
        
        return .result()
    }
}
