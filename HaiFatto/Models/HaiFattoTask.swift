// Hai fatto? — Main Task Model
import Foundation
import SwiftData
import SwiftUI

@Model
public final class HaiFattoTask {
    public var id: UUID
    public var name: String
    public var icon: String
    public var colorHex: String
    public var isCompleted: Bool
    public var lastCompletedAt: Date?
    public var resetIntervalHours: Int
    public var resetTime: Date
    public var notificationEnabled: Bool
    public var notificationTime: Date?
    public var requiresPhoto: Bool
    public var photoData: Data?
    public var isShared: Bool
    public var sharedWith: [String]
    public var createdAt: Date
    public var updatedAt: Date
    public var sortOrder: Int
    public var completionHistory: [Date]
    
    public init(
        id: UUID = UUID(),
        name: String,
        icon: String = "checkmark.circle",
        colorHex: String = "#007AFF",
        isCompleted: Bool = false,
        lastCompletedAt: Date? = nil,
        resetIntervalHours: Int = 24,
        resetTime: Date? = nil,
        notificationEnabled: Bool = false,
        notificationTime: Date? = nil,
        requiresPhoto: Bool = false,
        photoData: Data? = nil,
        isShared: Bool = false,
        sharedWith: [String] = [],
        createdAt: Date = .now,
        updatedAt: Date = .now,
        sortOrder: Int = 0,
        completionHistory: [Date] = []
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.isCompleted = isCompleted
        self.lastCompletedAt = lastCompletedAt
        self.resetIntervalHours = resetIntervalHours
        self.resetTime = resetTime ?? Self.nextResetTime(from: .now, intervalHours: resetIntervalHours)
        self.notificationEnabled = notificationEnabled
        self.notificationTime = notificationTime
        self.requiresPhoto = requiresPhoto
        self.photoData = photoData
        self.isShared = isShared
        self.sharedWith = sharedWith
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.sortOrder = sortOrder
        self.completionHistory = completionHistory
    }
    
    @Transient
    public var color: Color {
        Color(hex: colorHex)
    }
    
    @Transient
    public var shouldReset: Bool {
        Date.now >= resetTime
    }
    
    @Transient
    public var needsPhotoVerification: Bool {
        requiresPhoto && !isCompleted
    }
    
    public func toggleCompletion() {
        isCompleted.toggle()
        updatedAt = .now
        
        if isCompleted {
            lastCompletedAt = .now
            completionHistory.append(.now)
            resetTime = Self.nextResetTime(from: .now, intervalHours: resetIntervalHours)
        }
    }
    
    public func resetIfNeeded() {
        if shouldReset {
            isCompleted = false
            resetTime = Self.nextResetTime(from: .now, intervalHours: resetIntervalHours)
            updatedAt = .now
        }
    }
    
    public static func nextResetTime(from date: Date, intervalHours: Int) -> Date {
        let calendar = Calendar.current
        if intervalHours == 24 {
            // Default to next midnight
            if let nextDay = calendar.date(byAdding: .day, value: 1, to: date) {
                return calendar.startOfDay(for: nextDay)
            }
        }
        return calendar.date(byAdding: .hour, value: intervalHours, to: date) ?? date
    }
}

public extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
