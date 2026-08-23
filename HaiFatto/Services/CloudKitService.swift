// Hai fatto? — CloudKitService
import Foundation
import CloudKit
import SwiftData

@Observable
public class CloudKitService {
    public var isSyncing: Bool = false
    public var lastSyncDate: Date? = nil
    public var syncError: String? = nil
    
    private let container = CKContainer.default()
    private let privateDB: CKDatabase
    private let publicDB: CKDatabase
    private let recordType = "HaiFattoTask"
    
    public init() {
        self.privateDB = CKContainer.default().privateCloudDatabase
        self.publicDB = CKContainer.default().publicCloudDatabase
    }
    
    public func syncTasks(modelContext: ModelContext) async {
        isSyncing = true
        syncError = nil
        
        do {
            let descriptor = FetchDescriptor<HaiFattoTask>()
            let localTasks = try modelContext.fetch(descriptor)
            
            // Upload local tasks
            for task in localTasks {
                try await saveTask(task)
            }
            
            // Fetch remote tasks
            let remoteRecords = try await fetchRemoteTasks()
            
            for record in remoteRecords {
                let values = recordToTaskValues(record)
                if let idString = values["id"] as? String, let id = UUID(uuidString: idString) {
                    if let localTask = localTasks.first(where: { $0.id == id }) {
                        if let remoteUpdatedAt = values["updatedAt"] as? Date {
                            if remoteUpdatedAt > localTask.updatedAt {
                                updateLocalTask(localTask, with: values)
                            }
                        }
                    } else {
                        let newTask = createLocalTask(from: values)
                        modelContext.insert(newTask)
                    }
                }
            }
            
            try modelContext.save()
            lastSyncDate = Date()
        } catch {
            syncError = error.localizedDescription
        }
        
        isSyncing = false
    }
    
    public func saveTask(_ task: HaiFattoTask) async throws {
        let record = taskToRecord(task)
        try await privateDB.save(record)
    }
    
    public func fetchRemoteTasks() async throws -> [CKRecord] {
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        let (matchResults, _) = try await privateDB.records(matching: query)
        var records: [CKRecord] = []
        for match in matchResults {
            if case .success(let record) = match.1 {
                records.append(record)
            }
        }
        return records
    }
    
    public func deleteTask(_ task: HaiFattoTask) async throws {
        let recordID = CKRecord.ID(recordName: task.id.uuidString)
        try await privateDB.deleteRecord(withID: recordID)
    }
    
    public func setupSubscription() async throws {
        let subscriptionID = "haifatto-tasks-changes"
        let subscription = CKQuerySubscription(recordType: recordType,
                                               predicate: NSPredicate(value: true),
                                               subscriptionID: subscriptionID,
                                               options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion])
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo
        
        do {
            try await privateDB.save(subscription)
        } catch CKError.serverRejectedRequest {
            // Subscription probably already exists
        }
    }
    
    private func taskToRecord(_ task: HaiFattoTask) -> CKRecord {
        let recordID = CKRecord.ID(recordName: task.id.uuidString)
        let record = CKRecord(recordType: recordType, recordID: recordID)
        
        record["id"] = task.id.uuidString as CKRecordValue
        record["name"] = task.name as CKRecordValue
        record["icon"] = task.icon as CKRecordValue
        record["colorHex"] = task.colorHex as CKRecordValue
        record["isCompleted"] = task.isCompleted as CKRecordValue
        record["lastCompletedAt"] = task.lastCompletedAt as CKRecordValue?
        record["resetIntervalHours"] = task.resetIntervalHours as CKRecordValue
        record["resetTime"] = task.resetTime as CKRecordValue
        record["notificationEnabled"] = task.notificationEnabled as CKRecordValue
        record["notificationTime"] = task.notificationTime as CKRecordValue?
        record["requiresPhoto"] = task.requiresPhoto as CKRecordValue
        record["photoData"] = task.photoData as CKRecordValue?
        record["isShared"] = task.isShared as CKRecordValue
        record["sharedWith"] = task.sharedWith as CKRecordValue
        record["createdAt"] = task.createdAt as CKRecordValue
        record["updatedAt"] = task.updatedAt as CKRecordValue
        record["sortOrder"] = task.sortOrder as CKRecordValue
        record["completionHistory"] = task.completionHistory as CKRecordValue
        
        return record
    }
    
    private func recordToTaskValues(_ record: CKRecord) -> [String: Any] {
        var values: [String: Any] = [:]
        
        values["id"] = record["id"]
        values["name"] = record["name"]
        values["icon"] = record["icon"]
        values["colorHex"] = record["colorHex"]
        values["isCompleted"] = record["isCompleted"]
        values["lastCompletedAt"] = record["lastCompletedAt"]
        values["resetIntervalHours"] = record["resetIntervalHours"]
        values["resetTime"] = record["resetTime"]
        values["notificationEnabled"] = record["notificationEnabled"]
        values["notificationTime"] = record["notificationTime"]
        values["requiresPhoto"] = record["requiresPhoto"]
        values["photoData"] = record["photoData"]
        values["isShared"] = record["isShared"]
        values["sharedWith"] = record["sharedWith"]
        values["createdAt"] = record["createdAt"]
        values["updatedAt"] = record["updatedAt"]
        values["sortOrder"] = record["sortOrder"]
        values["completionHistory"] = record["completionHistory"]
        
        return values
    }
    
    private func updateLocalTask(_ task: HaiFattoTask, with values: [String: Any]) {
        task.name = values["name"] as? String ?? task.name
        task.icon = values["icon"] as? String ?? task.icon
        task.colorHex = values["colorHex"] as? String ?? task.colorHex
        task.isCompleted = values["isCompleted"] as? Bool ?? task.isCompleted
        task.lastCompletedAt = values["lastCompletedAt"] as? Date
        task.resetIntervalHours = values["resetIntervalHours"] as? Int ?? task.resetIntervalHours
        task.resetTime = values["resetTime"] as? Date ?? task.resetTime
        task.notificationEnabled = values["notificationEnabled"] as? Bool ?? task.notificationEnabled
        task.notificationTime = values["notificationTime"] as? Date
        task.requiresPhoto = values["requiresPhoto"] as? Bool ?? task.requiresPhoto
        task.photoData = values["photoData"] as? Data
        task.isShared = values["isShared"] as? Bool ?? task.isShared
        task.sharedWith = values["sharedWith"] as? [String] ?? task.sharedWith
        task.createdAt = values["createdAt"] as? Date ?? task.createdAt
        task.updatedAt = values["updatedAt"] as? Date ?? task.updatedAt
        task.sortOrder = values["sortOrder"] as? Int ?? task.sortOrder
        task.completionHistory = values["completionHistory"] as? [Date] ?? task.completionHistory
    }
    
    private func createLocalTask(from values: [String: Any]) -> HaiFattoTask {
        let task = HaiFattoTask(
            id: UUID(uuidString: values["id"] as? String ?? "") ?? UUID(),
            name: values["name"] as? String ?? "",
            icon: values["icon"] as? String ?? "checkmark",
            colorHex: values["colorHex"] as? String ?? "#000000",
            isCompleted: values["isCompleted"] as? Bool ?? false,
            lastCompletedAt: values["lastCompletedAt"] as? Date,
            resetIntervalHours: values["resetIntervalHours"] as? Int ?? 24,
            resetTime: values["resetTime"] as? Date ?? Date(),
            notificationEnabled: values["notificationEnabled"] as? Bool ?? false,
            notificationTime: values["notificationTime"] as? Date,
            requiresPhoto: values["requiresPhoto"] as? Bool ?? false,
            photoData: values["photoData"] as? Data,
            isShared: values["isShared"] as? Bool ?? false,
            sharedWith: values["sharedWith"] as? [String] ?? [],
            createdAt: values["createdAt"] as? Date ?? Date(),
            updatedAt: values["updatedAt"] as? Date ?? Date(),
            sortOrder: values["sortOrder"] as? Int ?? 0,
            completionHistory: values["completionHistory"] as? [Date] ?? []
        )
        return task
    }
}
