// Hai fatto? — App Entry Point
import SwiftUI
import SwiftData

@main
struct HaiFattoApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    let container: ModelContainer
    @State private var storeKitService = StoreKitService()
    @State private var cloudKitService = CloudKitService()
    
    init() {
        do {
            guard let url = AppGroup.sharedContainerURL else {
                fatalError("Could not find App Group container URL")
            }
            let storeURL = url.appendingPathComponent("HaiFatto.sqlite")
            let schema = Schema([HaiFattoTask.self, UserProfile.self])
            let modelConfiguration = ModelConfiguration(schema: schema, url: storeURL)
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not initialize SwiftData container: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(\.modelContext, container.mainContext)
                .environment(storeKitService)
                .environment(cloudKitService)
                .onAppear {
                    NotificationService.registerCategories()
                    TaskResetService.resetAllTasksIfNeeded(modelContext: container.mainContext)
                    syncSharedTasks()
                    Task {
                        await storeKitService.loadProducts()
                        await storeKitService.updatePurchasedProducts()
                    }
                }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                TaskResetService.resetAllTasksIfNeeded(modelContext: container.mainContext)
                syncSharedTasks()
            }
        }
    }
    
    private func syncSharedTasks() {
        do {
            let descriptor = FetchDescriptor<HaiFattoTask>()
            let tasks = try container.mainContext.fetch(descriptor)
            SharedTaskStore.saveTasks(tasks)
        } catch {
            print("Failed to fetch tasks for sharing: \(error)")
        }
    }
}

struct AppRootView: View {
    @Query private var profiles: [UserProfile]
    @Environment(\.modelContext) private var context
    
    var body: some View {
        Group {
            if let profile = profiles.first {
                if profile.hasSeenOnboarding {
                    HomeView()
                } else {
                    OnboardingView(profile: profile)
                }
            } else {
                ProgressView()
                    .onAppear {
                        let newProfile = UserProfile()
                        context.insert(newProfile)
                    }
            }
        }
    }
}
