// Hai fatto? — TaskResetService
import Foundation
import SwiftData
import BackgroundTasks

public enum TaskResetService {
    
    @MainActor
    public static func resetAllTasksIfNeeded(modelContext: ModelContext) {
        do {
            let descriptor = FetchDescriptor<HaiFattoTask>()
            let tasks = try modelContext.fetch(descriptor)
            
            var hasChanges = false
            for task in tasks {
                if task.shouldReset {
                    task.resetIfNeeded()
                    hasChanges = true
                }
            }
            
            if hasChanges {
                try modelContext.save()
            }
        } catch {
            print("Failed to reset tasks: \(error)")
        }
    }
    
    public static func scheduleBackgroundReset() {
        let request = BGAppRefreshTaskRequest(identifier: "com.haifatto.taskreset")
        
        // Schedule for next midnight
        let calendar = Calendar.current
        if let nextMidnight = calendar.nextDate(
            after: Date(),
            matching: DateComponents(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTime
        ) {
            request.earliestBeginDate = nextMidnight
        }
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    @MainActor
    public static func handleBackgroundReset(modelContext: ModelContext) async {
        resetAllTasksIfNeeded(modelContext: modelContext)
        
        do {
            let descriptor = FetchDescriptor<HaiFattoTask>()
            let tasks = try modelContext.fetch(descriptor)
            SharedTaskStore.saveTasks(tasks)
        } catch {
            print("Failed to fetch tasks for shared store: \(error)")
        }
        
        scheduleBackgroundReset()
    }
}
