// Hai fatto? — HomeView
import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \HaiFattoTask.sortOrder) var tasks: [HaiFattoTask]
    @Environment(\.modelContext) var modelContext
    @Environment(StoreKitService.self) var storeKitService
    @Environment(CloudKitService.self) var cloudKitService
    
    @State private var showingAddTask = false
    @State private var showingSettings = false
    @State private var showConfetti = false
    @State private var showingPremiumUpgrade = false
    @State private var selectedTask: HaiFattoTask?
    
    var body: some View {
        NavigationStack {
            ZStack {
                if tasks.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "checklist")
                            .font(.system(size: 80))
                            .foregroundStyle(.secondary)
                        Text(String(localized: "home_empty_title"))
                            .font(.title2)
                            .bold()
                        Text(String(localized: "home_empty_subtitle"))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: { showingAddTask = true }) {
                            Text(String(localized: "home_add_first_task"))
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding()
                                .background(Color.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(.top, 10)
                    }
                } else {
                    List {
                        ForEach(tasks) { task in
                            TaskRowView(
                                task: task,
                                isPremium: storeKitService.isPremium,
                                onToggle: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        task.toggleCompletion()
                                    }
                                    checkConfetti()
                                    SharedTaskStore.saveTasks(tasks)
                                },
                                onEdit: {
                                    selectedTask = task
                                },
                                onDelete: {
                                    NotificationService.cancelNotification(for: task.id)
                                    modelContext.delete(task)
                                    SharedTaskStore.saveTasks(tasks)
                                }
                            )
                        }
                        .onDelete(perform: deleteTasks)
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await cloudKitService.syncTasks(modelContext: modelContext)
                        SharedTaskStore.saveTasks(tasks)
                    }
                }
                
                if showConfetti {
                    ConfettiView(isActive: $showConfetti)
                }
            }
            .navigationTitle("Hai fatto?")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gear")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        if !storeKitService.isPremium && tasks.count >= 1 {
                            showingPremiumUpgrade = true
                        } else {
                            showingAddTask = true
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                NavigationStack {
                    TaskDetailView(task: nil)
                }
            }
            .sheet(item: $selectedTask) { task in
                NavigationStack {
                    TaskDetailView(task: task)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .alert(String(localized: "premium_upgrade_title"), isPresented: $showingPremiumUpgrade) {
                Button(String(localized: "general_cancel"), role: .cancel) { }
                Button(String(localized: "premium_upgrade_button")) {
                    showingSettings = true
                }
            } message: {
                Text(String(localized: "premium_upgrade_message"))
            }
            .onAppear {
                for task in tasks {
                    task.resetIfNeeded()
                }
                SharedTaskStore.saveTasks(tasks)
            }
        }
    }
    
    private func deleteTasks(offsets: IndexSet) {
        for index in offsets {
            let task = tasks[index]
            if task.notificationEnabled {
                NotificationService.cancelNotification(for: task.id)
            }
            modelContext.delete(task)
        }
        SharedTaskStore.saveTasks(tasks)
    }
    
    private func checkConfetti() {
        if !tasks.isEmpty && tasks.allSatisfy({ $0.isCompleted }) {
            withAnimation(.spring()) {
                showConfetti = true
            }
        }
    }
}
