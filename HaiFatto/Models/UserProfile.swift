// Hai fatto? — User Profile Model
import Foundation
import SwiftData

@Model
public final class UserProfile {
    public var id: UUID
    public var name: String
    public var email: String?
    public var isPremium: Bool
    public var premiumExpiry: Date?
    public var hasSeenOnboarding: Bool
    
    public init(
        id: UUID = UUID(),
        name: String = String(localized: "User"),
        email: String? = nil,
        isPremium: Bool = false,
        premiumExpiry: Date? = nil,
        hasSeenOnboarding: Bool = false
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.isPremium = isPremium
        self.premiumExpiry = premiumExpiry
        self.hasSeenOnboarding = hasSeenOnboarding
    }
    
    @Transient
    public var isPremiumActive: Bool {
        if isPremium {
            if let expiry = premiumExpiry {
                return expiry > Date.now
            }
            return true
        }
        return false
    }
}
