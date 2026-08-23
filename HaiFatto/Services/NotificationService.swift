// Hai fatto? — NotificationService
import Foundation
import UserNotifications

@Observable
public class NotificationService {
    
    public init() {}
    
    public static func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            return false
        }
    }
    
    public static func registerCategories() {
        let completeAction = UNNotificationAction(identifier: "COMPLETE", title: String(localized: "notification_action_complete"), options: [.foreground])
        let snooze15Action = UNNotificationAction(identifier: "SNOOZE_15", title: String(localized: "notification_action_snooze_15"), options: [])
        let snooze60Action = UNNotificationAction(identifier: "SNOOZE_60", title: String(localized: "notification_action_snooze_60"), options: [])
        
        let taskReminderCategory = UNNotificationCategory(identifier: "TASK_REMINDER",
                                                          actions: [completeAction, snooze15Action, snooze60Action],
                                                          intentIdentifiers: [],
                                                          options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([taskReminderCategory])
    }
    
    public static func scheduleNotification(for task: HaiFattoTask) {
        guard task.notificationEnabled, let notificationTime = task.notificationTime else { return }
        
        let content = UNMutableNotificationContent()
        content.title = String(localized: "notification_reminder_title")
        content.body = task.name
        content.sound = .default
        content.categoryIdentifier = "TASK_REMINDER"
        content.userInfo = ["taskId": task.id.uuidString]
        
        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    public static func snoozeNotification(for taskId: UUID, minutes: Int) {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "notification_reminder_title")
        content.body = String(localized: "notification_snooze_body")
        content.sound = .default
        content.categoryIdentifier = "TASK_REMINDER"
        content.userInfo = ["taskId": taskId.uuidString]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(minutes * 60), repeats: false)
        
        let request = UNNotificationRequest(identifier: "\(taskId.uuidString)_snooze", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling snooze notification: \(error)")
            }
        }
    }
    
    public static func cancelNotification(for taskId: UUID) {
        let identifiers = [taskId.uuidString, "\(taskId.uuidString)_snooze"]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    public static func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    public static func updateBadgeCount(pendingTasks: Int) {
        UNUserNotificationCenter.current().setBadgeCount(pendingTasks) { error in
            if let error = error {
                print("Error updating badge count: \(error)")
            }
        }
    }
}
