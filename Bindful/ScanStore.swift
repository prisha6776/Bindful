import Foundation
import Combine

final class ScanStore: ObservableObject {
    static let shared = ScanStore()

    @Published private(set) var records: [ScanRecord] = []
    @Published private(set) var streak: Int = 0

    private init() {
        load()
        recalculateStreak()
    }

    // MARK: Derived stats

    var itemsDiverted: Int {
        records.filter { $0.category != .trash }.count
    }

    var recycleCount: Int { records.filter { $0.category == .recycle }.count }
    var compostCount: Int { records.filter { $0.category == .compost }.count }
    var trashCount:   Int { records.filter { $0.category == .trash   }.count }

    var motivationMessage: String {
        switch itemsDiverted {
        case 0:       return "Scan your first item to get started!"
        case 1...4:   return "Great start, keep it going!"
        case 5...14:  return "You're making a difference!"
        case 15...29: return "Eco hero in the making!"
        default:      return "You're a Bindful legend!"
        }
    }

    // MARK: Mutations

    func add(_ record: ScanRecord) {
        records.insert(record, at: 0)
        save()
        recalculateStreak()
    }

    // MARK: Streak

    private func recalculateStreak() {
        // count backwards from today, one day at a time, until we hit a day with no scans
        let calendar = Calendar.current
        let scanDays = Set(records.map { calendar.startOfDay(for: $0.date) })
        var count = 0
        var day = calendar.startOfDay(for: Date())
        while scanDays.contains(day) {
            count += 1
            day = calendar.date(byAdding: .day, value: -1, to: day)!
        }
        streak = count
    }

    // MARK: Persistence

    private let storageKey = "ecolens_scan_records"

    private func save() {
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func load() {
        guard
            let data    = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([ScanRecord].self, from: data)
        else { return }
        records = decoded
    }
}
