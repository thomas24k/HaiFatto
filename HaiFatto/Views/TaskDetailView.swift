// Hai fatto? — TaskDetailView
import SwiftUI
import SwiftData

struct TaskDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Environment(StoreKitService.self) var storeKitService
    
    var task: HaiFattoTask?
    
    @State private var name: String = ""
    @State private var selectedIcon: String = "checkmark.circle"
    @State private var selectedColorHex: String = "#007AFF"
    @State private var showingIconPicker = false
    
    @State private var resetIntervalHours: Int = 24
    @State private var resetTime: Date = Date()
    
    @State private var notificationEnabled: Bool = false
    @State private var notificationTime: Date = Date()
    
    @State private var requiresPhoto: Bool = false
    @State private var isShared: Bool = false
    @State private var sharedWithText: String = ""
    @State private var showingDeleteAlert = false
    
    let colorPalette = [
        "#FF3B30", "#FF9500", "#FFCC00", "#34C759",
        "#5AC8FA", "#007AFF", "#5856D6", "#FF2D55",
        "#AF52DE", "#A2845E", "#8E8E93", "#000000"
    ]
    
    let intervalOptions: [(String, Int)] = [
        ("Every 12 hours", 12),
        ("Daily", 24),
        ("Every 2 days", 48),
        ("Weekly", 168)
    ]
    
    init(task: HaiFattoTask? = nil) {
        self.task = task
    }
    
    var body: some View {
        Form {
            // MARK: - Task Info
            Section(header: Text(String(localized: "task_info_section"))) {
                TextField(String(localized: "task_name_placeholder"), text: $name)
                
                Button(action: { showingIconPicker = true }) {
                    HStack {
                        Text(String(localized: "task_icon_label"))
                        Spacer()
                        Image(systemName: selectedIcon)
                            .foregroundStyle(Color(hex: selectedColorHex))
                            .font(.title2)
                    }
                }
                .foregroundStyle(.primary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(colorPalette, id: \.self) { hex in
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: selectedColorHex == hex ? 3 : 0)
                                )
                                .onTapGesture {
                                    selectedColorHex = hex
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            
            // MARK: - Schedule
            Section(header: Text(String(localized: "task_schedule_section"))) {
                Picker(String(localized: "task_reset_interval_label"), selection: $resetIntervalHours) {
                    ForEach(intervalOptions, id: \.1) { option in
                        Text(option.0).tag(option.1)
                    }
                }
                
                DatePicker(String(localized: "task_reset_time_label"), selection: $resetTime, displayedComponents: .hourAndMinute)
            }
            
            // MARK: - Notifications
            Section(header: Text(String(localized: "task_notifications_section"))) {
                Toggle(String(localized: "task_notifications_enable"), isOn: $notificationEnabled)
                if notificationEnabled {
                    DatePicker(String(localized: "task_notifications_time"), selection: $notificationTime, displayedComponents: .hourAndMinute)
                    Text(String(localized: "task_notifications_snooze_hint"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // MARK: - Premium Features
            if storeKitService.isPremium {
                Section(header: Text(String(localized: "task_photo_verification_section"))) {
                    Toggle(String(localized: "task_requires_photo_label"), isOn: $requiresPhoto)
                    if requiresPhoto {
                        Button(action: {
                            // Camera picker integration point
                        }) {
                            HStack {
                                Image(systemName: "camera")
                                Text(String(localized: "task_camera_button"))
                            }
                        }
                    }
                }
                
                Section(header: Text(String(localized: "task_sharing_section"))) {
                    Toggle(String(localized: "task_is_shared_label"), isOn: $isShared)
                    if isShared {
                        TextField(String(localized: "task_shared_with_placeholder"), text: $sharedWithText)
                    }
                }
            } else {
                Section(header: Text(String(localized: "task_premium_features_section"))) {
                    Text(String(localized: "task_premium_locked_message"))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            
            // MARK: - Delete
            if task != nil {
                Section {
                    Button(role: .destructive, action: {
                        showingDeleteAlert = true
                    }) {
                        HStack {
                            Spacer()
                            Text(String(localized: "general_delete"))
                            Spacer()
                        }
                    }
                }
            }
        }
        .navigationTitle(task == nil ? String(localized: "task_new_title") : String(localized: "task_edit_title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(String(localized: "general_cancel")) {
                    dismiss()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(String(localized: "general_save")) {
                    saveTask()
                }
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                .bold()
            }
        }
        .sheet(isPresented: $showingIconPicker) {
            IconPickerView(selectedIcon: $selectedIcon)
        }
        .alert(String(localized: "task_delete_title"), isPresented: $showingDeleteAlert) {
            Button(String(localized: "general_cancel"), role: .cancel) { }
            Button(String(localized: "general_delete"), role: .destructive) {
                deleteTask()
            }
        } message: {
            Text(String(localized: "task_delete_message"))
        }
        .onAppear {
            if let task = task {
                name = task.name
                selectedIcon = task.icon
                selectedColorHex = task.colorHex
                resetIntervalHours = task.resetIntervalHours
                resetTime = task.resetTime
                notificationEnabled = task.notificationEnabled
                if let nt = task.notificationTime {
                    notificationTime = nt
                }
                requiresPhoto = task.requiresPhoto
                isShared = task.isShared
                sharedWithText = task.sharedWith.joined(separator: ", ")
            }
        }
    }
    
    private func saveTask() {
        let taskToSave: HaiFattoTask
        if let existing = task {
            existing.name = name
            existing.icon = selectedIcon
            existing.colorHex = selectedColorHex
            existing.resetIntervalHours = resetIntervalHours
            existing.resetTime = resetTime
            existing.notificationEnabled = notificationEnabled
            existing.notificationTime = notificationEnabled ? notificationTime : nil
            existing.requiresPhoto = storeKitService.isPremium ? requiresPhoto : false
            existing.isShared = storeKitService.isPremium ? isShared : false
            existing.sharedWith = storeKitService.isPremium
                ? sharedWithText.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
                : []
            existing.updatedAt = Date()
            taskToSave = existing
        } else {
            let newTask = HaiFattoTask(
                name: name,
                icon: selectedIcon,
                colorHex: selectedColorHex,
                resetIntervalHours: resetIntervalHours,
                resetTime: resetTime,
                notificationEnabled: notificationEnabled,
                notificationTime: notificationEnabled ? notificationTime : nil,
                requiresPhoto: storeKitService.isPremium ? requiresPhoto : false,
                isShared: storeKitService.isPremium ? isShared : false,
                sharedWith: storeKitService.isPremium
                    ? sharedWithText.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
                    : []
            )
            modelContext.insert(newTask)
            taskToSave = newTask
        }
        
        if taskToSave.notificationEnabled {
            NotificationService.scheduleNotification(for: taskToSave)
        } else {
            NotificationService.cancelNotification(for: taskToSave.id)
        }
        
        dismiss()
    }
    
    private func deleteTask() {
        if let task = task {
            if task.notificationEnabled {
                NotificationService.cancelNotification(for: task.id)
            }
            modelContext.delete(task)
            dismiss()
        }
    }
}
