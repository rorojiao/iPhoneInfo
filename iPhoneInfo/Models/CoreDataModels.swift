//
//  CoreDataModels.swift
//  iPhoneInfo
//
//  CoreData models for persistent storage
//

import Foundation
import CoreData
import SwiftUI

// MARK: - BenchmarkResult Entity
@objc(BenchmarkResultEntity)
public class BenchmarkResultEntity: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var deviceModel: String
    @NSManaged public var deviceName: String
    @NSManaged public var cpuScore: Int
    @NSManaged public var gpuScore: Int
    @NSManaged public var memoryScore: Int
    @NSManaged public var storageScore: Int
    @NSManaged public var totalScore: Int
    @NSManaged public var grade: String
    @NSManaged public var testType: String
    @NSManaged public var testDuration: Double
    @NSManaged public var details: String?
}

// MARK: - CoreData Stack
class CoreDataStack {
    static let shared = CoreDataStack()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "iPhoneInfo")

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("CoreData store loading failed: \(error)")
            }
        }

        return container
    }()

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    private init() {}

    func save() {
        let context = persistentContainer.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("CoreData save failed: \(error)")
            }
        }
    }
}

// MARK: - Benchmark History Manager
class BenchmarkHistoryManager: ObservableObject {
    static let shared = BenchmarkHistoryManager()

    @Published var history: [BenchmarkRecord] = []

    private let context = CoreDataStack.shared.context

    private init() {
        loadHistory()
    }

    // MARK: - Save Benchmark Result
    func saveResult(
        cpuScore: Int,
        gpuScore: Int,
        memoryScore: Int,
        storageScore: Int,
        totalScore: Int,
        grade: String,
        testType: String,
        testDuration: TimeInterval,
        details: String? = nil
    ) {
        let entity = BenchmarkResultEntity(context: context)
        entity.id = UUID()
        entity.date = Date()
        entity.deviceModel = getDeviceModel()
        entity.deviceName = UIDevice.current.name
        entity.cpuScore = cpuScore
        entity.gpuScore = gpuScore
        entity.memoryScore = memoryScore
        entity.storageScore = storageScore
        entity.totalScore = totalScore
        entity.grade = grade
        entity.testType = testType
        entity.testDuration = testDuration
        entity.details = details

        CoreDataStack.shared.save()

        loadHistory()
    }

    // MARK: - Load History
    func loadHistory() {
        let request: NSFetchRequest<BenchmarkResultEntity> = BenchmarkResultEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \BenchmarkResultEntity.date, ascending: false)]

        do {
            let entities = try context.fetch(request)
            history = entities.map { entity in
                BenchmarkRecord(
                    id: entity.id,
                    date: entity.date,
                    deviceModel: entity.deviceModel,
                    deviceName: entity.deviceName,
                    cpuScore: entity.cpuScore,
                    gpuScore: entity.gpuScore,
                    memoryScore: entity.memoryScore,
                    storageScore: entity.storageScore,
                    totalScore: entity.totalScore,
                    grade: entity.grade,
                    testType: entity.testType,
                    testDuration: entity.testDuration,
                    details: entity.details
                )
            }
        } catch {
            print("Failed to fetch history: \(error)")
            history = []
        }
    }

    // MARK: - Delete Result
    func deleteResult(id: UUID) {
        let request: NSFetchRequest<BenchmarkResultEntity> = BenchmarkResultEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            let entities = try context.fetch(request)
            for entity in entities {
                context.delete(entity)
            }
            CoreDataStack.shared.save()
            loadHistory()
        } catch {
            print("Failed to delete result: \(error)")
        }
    }

    // MARK: - Clear All History
    func clearHistory() {
        let request: NSFetchRequest<NSFetchRequestResult> = BenchmarkResultEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)

        do {
            try context.execute(deleteRequest)
            CoreDataStack.shared.save()
            loadHistory()
        } catch {
            print("Failed to clear history: \(error)")
        }
    }

    // MARK: - Get Best Scores
    func getBestScores() -> (cpu: Int?, gpu: Int?, memory: Int?, storage: Int?) {
        var bestCPU: Int?
        var bestGPU: Int?
        var bestMemory: Int?
        var bestStorage: Int?

        for record in history {
            if bestCPU == nil || record.cpuScore > (bestCPU ?? 0) {
                bestCPU = record.cpuScore
            }
            if bestGPU == nil || record.gpuScore > (bestGPU ?? 0) {
                bestGPU = record.gpuScore
            }
            if bestMemory == nil || record.memoryScore > (bestMemory ?? 0) {
                bestMemory = record.memoryScore
            }
            if bestStorage == nil || record.storageScore > (bestStorage ?? 0) {
                bestStorage = record.storageScore
            }
        }

        return (bestCPU, bestGPU, bestMemory, bestStorage)
    }

    // MARK: - Get Average Scores
    func getAverageScores() -> (cpu: Double, gpu: Double, memory: Double, storage: Double) {
        guard !history.isEmpty else {
            return (0, 0, 0, 0)
        }

        let totalCPU = history.reduce(0) { $0 + $1.cpuScore }
        let totalGPU = history.reduce(0) { $0 + $1.gpuScore }
        let totalMemory = history.reduce(0) { $0 + $1.memoryScore }
        let totalStorage = history.reduce(0) { $0 + $1.storageScore }

        let count = Double(history.count)

        return (
            Double(totalCPU) / count,
            Double(totalGPU) / count,
            Double(totalMemory) / count,
            Double(totalStorage) / count
        )
    }

    // MARK: - Export History
    func exportToJSON() -> String? {
        let exportData = history.map { record in
            [
                "id": record.id.uuidString,
                "date": ISO8601DateFormatter().string(from: record.date),
                "deviceModel": record.deviceModel,
                "deviceName": record.deviceName,
                "cpuScore": record.cpuScore,
                "gpuScore": record.gpuScore,
                "memoryScore": record.memoryScore,
                "storageScore": record.storageScore,
                "totalScore": record.totalScore,
                "grade": record.grade,
                "testType": record.testType,
                "testDuration": record.testDuration
            ]
        }

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            print("Failed to export JSON: \(error)")
            return nil
        }
    }

    // MARK: - Import History
    func importFromJSON(jsonString: String) -> Bool {
        guard let data = jsonString.data(using: .utf8) else { return false }

        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                for item in jsonArray {
                    if let idString = item["id"] as? String,
                       let id = UUID(uuidString: idString),
                       let dateString = item["date"] as? String,
                       let date = ISO8601DateFormatter().date(from: dateString),
                       let deviceModel = item["deviceModel"] as? String,
                       let deviceName = item["deviceName"] as? String,
                       let cpuScore = item["cpuScore"] as? Int,
                       let gpuScore = item["gpuScore"] as? Int,
                       let memoryScore = item["memoryScore"] as? Int,
                       let storageScore = item["storageScore"] as? Int,
                       let totalScore = item["totalScore"] as? Int,
                       let grade = item["grade"] as? String,
                       let testType = item["testType"] as? String,
                       let testDuration = item["testDuration"] as? Double {

                        let entity = BenchmarkResultEntity(context: context)
                        entity.id = id
                        entity.date = date
                        entity.deviceModel = deviceModel
                        entity.deviceName = deviceName
                        entity.cpuScore = cpuScore
                        entity.gpuScore = gpuScore
                        entity.memoryScore = memoryScore
                        entity.storageScore = storageScore
                        entity.totalScore = totalScore
                        entity.grade = grade
                        entity.testType = testType
                        entity.testDuration = testDuration
                    }
                }

                CoreDataStack.shared.save()
                loadHistory()
                return true
            }
        } catch {
            print("Failed to import JSON: \(error)")
        }

        return false
    }

    // MARK: - Helper
    private func getDeviceModel() -> String {
        var size: Int = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        return String(cString: machine)
    }
}

// MARK: - Benchmark Record Model
struct BenchmarkRecord: Identifiable {
    let id: UUID
    let date: Date
    let deviceModel: String
    let deviceName: String
    let cpuScore: Int
    let gpuScore: Int
    let memoryScore: Int
    let storageScore: Int
    let totalScore: Int
    let grade: String
    let testType: String
    let testDuration: TimeInterval
    let details: String?

    var gradeColor: Color {
        switch grade {
        case "S": return .purple
        case "A": return .green
        case "B": return .blue
        case "C": return .orange
        case "D": return .red
        default: return .gray
        }
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }

    var formattedDuration: String {
        if testDuration < 60 {
            return String(format: "%.0f 秒", testDuration)
        } else {
            let minutes = Int(testDuration / 60)
            let seconds = Int(testDuration) % 60
            return "\(minutes) 分 \(seconds) 秒"
        }
    }
}

// MARK: - CoreData Model Extension
extension BenchmarkResultEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<BenchmarkResultEntity> {
        return NSFetchRequest<BenchmarkResultEntity>(entityName: "BenchmarkResultEntity")
    }
}
