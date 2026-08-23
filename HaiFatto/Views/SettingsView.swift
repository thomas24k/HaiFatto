// Hai fatto? — SettingsView
import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(StoreKitService.self) var storeKitService
    @Environment(CloudKitService.self) var cloudKitService
    @Environment(\.modelContext) var modelContext
    @Query var tasks: [HaiFattoTask]
    
    @State private var showingDeleteAlert = false
    @State private var isPurchasing = false
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Premium
                Section(header: Text(String(localized: "settings_premium_section"))) {
                    if storeKitService.isPremium {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                            Text(String(localized: "settings_premium_active"))
                                .bold()
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(String(localized: "settings_premium_marketing_title"))
                                .font(.title3)
                                .bold()
                            
                            VStack(alignment: .leading, spacing: 6) {
                                featureRow("checkmark.circle.fill", "settings_premium_feature_unlimited")
                                featureRow("widget.large", "settings_premium_feature_widgets")
                                featureRow("bell.badge", "settings_premium_feature_snooze")
                                featureRow("person.2", "settings_premium_feature_sharing")
                                featureRow("camera", "settings_premium_feature_photo")
                                featureRow("chart.bar", "settings_premium_feature_heatmap")
                            }
                        }
                        .padding(.vertical, 4)
                        
                        ForEach(storeKitService.products, id: \.id) { product in
                            Button(action: {
                                Task {
                                    isPurchasing = true
                                    _ = try? await storeKitService.purchase(product)
                                    isPurchasing = false
                                }
                            }) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(product.displayName)
                                            .font(.body)
                                            .foregroundStyle(.primary)
                                        Text(product.description)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text(product.displayPrice)
                                        .bold()
                                        .foregroundStyle(.blue)
                                }
                            }
                            .disabled(isPurchasing)
                        }
                        
                        Button(action: {
                            Task { await storeKitService.restorePurchases() }
                        }) {
                            Text(String(localized: "settings_premium_restore"))
                                .foregroundStyle(.blue)
                        }
                    }
                }
                
                // MARK: - Heatmap (Premium)
                if storeKitService.isPremium {
                    Section(header: Text(String(localized: "settings_heatmap_section"))) {
                        let allDates = tasks.flatMap { $0.completionHistory }
                        NavigationLink {
                            HeatmapView(completionDates: allDates)
                        } label: {
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                    .foregroundStyle(.green)
                                Text(String(localized: "settings_heatmap_view"))
                            }
                        }
                    }
                }
                
                // MARK: - Notifications
                Section(header: Text(String(localized: "settings_notifications_section"))) {
                    Button(action: {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "bell")
                            Text(String(localized: "settings_notifications_open_settings"))
                                .foregroundStyle(.primary)
                        }
                    }
                }
                
                // MARK: - Data
                Section(header: Text(String(localized: "settings_data_section"))) {
                    Button(action: {
                        Task {
                            await cloudKitService.syncTasks(modelContext: modelContext)
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text(String(localized: "settings_data_manual_sync"))
                                .foregroundStyle(.primary)
                            Spacer()
                            if cloudKitService.isSyncing {
                                ProgressView()
                            }
                        }
                    }
                    
                    if let lastSync = cloudKitService.lastSyncDate {
                        Text(String(localized: "settings_data_last_sync") + ": \(lastSync, style: .relative)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // MARK: - About
                Section(header: Text(String(localized: "settings_about_section"))) {
                    HStack {
                        Text(String(localized: "settings_about_version"))
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    Link(String(localized: "settings_about_privacy"), destination: URL(string: "https://haifatto.app/privacy")!)
                    Link(String(localized: "settings_about_contact"), destination: URL(string: "mailto:support@haifatto.app")!)
                }
                
                // MARK: - Danger Zone
                Section(header: Text(String(localized: "settings_danger_section"))) {
                    Button(role: .destructive, action: { showingDeleteAlert = true }) {
                        Text(String(localized: "settings_danger_delete_all"))
                    }
                }
            }
            .navigationTitle(String(localized: "settings_title"))
            .alert(String(localized: "settings_danger_alert_title"), isPresented: $showingDeleteAlert) {
                Button(String(localized: "general_cancel"), role: .cancel) { }
                Button(String(localized: "general_delete"), role: .destructive) {
                    deleteAllData()
                }
            } message: {
                Text(String(localized: "settings_danger_alert_message"))
            }
            .onAppear {
                Task {
                    await storeKitService.loadProducts()
                }
            }
        }
    }
    
    @ViewBuilder
    private func featureRow(_ icon: String, _ key: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 20)
            Text(String(localized: String.LocalizationValue(key)))
                .font(.subheadline)
        }
    }
    
    private func deleteAllData() {
        for task in tasks {
            modelContext.delete(task)
        }
        SharedTaskStore.saveTasks([])
    }
}
