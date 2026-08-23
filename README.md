# Hai fatto? 🇮🇹

A minimal iOS app for tracking recurring daily tasks with **interactive Home Screen widgets**.

## Features

- ✅ **One-tap task completion** — toggle tasks from the app or directly from widgets
- 🏠 **Interactive Widgets** — Small (1 task), Medium (3), Large (5) with toggle buttons
- ☁️ **iCloud Sync** — CloudKit synchronization across iPhone, iPad, Mac
- 🔔 **Smart Notifications** — Schedulable reminders with snooze (15 min / 1 hour)
- 🔄 **Auto-Reset** — Tasks reset on configurable intervals (12h, daily, 2 days, weekly)
- 📊 **Completion Heatmap** — GitHub-style history visualization (Premium)
- 📸 **Photo Verification** — Prove you did it with a photo (Premium)
- 👥 **Task Sharing** — Share tasks with other users (Premium)
- 🎉 **Confetti Celebration** — When all tasks are completed
- 🌍 **Multi-language** — English, Spanish, Italian

## Tech Stack

- **SwiftUI** — Native UI framework
- **SwiftData** — Local persistence with `@Model`
- **WidgetKit** — Interactive widgets with `AppIntent`
- **CloudKit** — iCloud synchronization
- **StoreKit 2** — In-App Purchases
- **UserNotifications** — Local notifications with actions

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Apple Developer Account (for CloudKit & IAP)

## Premium Plans

| Feature | Free | Premium |
|---------|------|---------|
| Tasks | 1 | Unlimited |
| Small Widget | ✅ | ✅ |
| Medium/Large Widgets | ❌ | ✅ |
| iCloud Sync | ✅ | ✅ |
| Snooze Notifications | ❌ | ✅ |
| Task Sharing | ❌ | ✅ |
| Photo Verification | ❌ | ✅ |
| Completion Heatmap | ❌ | ✅ |

**Pricing**: $0.99/month · $7.99/year · $17.99 lifetime

## Setup

1. Clone this repository
2. Open Xcode → Create new project → add source files
3. Add Widget Extension target ("HaiFattoWidgets")
4. Configure capabilities: App Groups, CloudKit, Push Notifications, Background Modes, IAP
5. Build and run!

## Privacy

No data collection. All data stored locally and in the user's private iCloud container. GDPR compliant.

## License

MIT
