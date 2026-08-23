// Hai fatto? — Shared App Group Constants
import Foundation

public struct AppGroup {
    public static let appGroupIdentifier = "group.com.haifatto.shared"
    public static let suiteName = appGroupIdentifier
    
    public static var sharedUserDefaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }
    
    public static let tasksKey = "shared_tasks"
    
    public static var sharedContainerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)
    }
}
