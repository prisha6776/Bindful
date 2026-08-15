import Foundation

struct ScanRecord: Identifiable, Codable {
    let id: UUID
    let date: Date
    let itemName: String
    let category: WasteCategory
    let confidence: Double
    let reason: String

    init(id: UUID = UUID(), date: Date = Date(), itemName: String,
         category: WasteCategory, confidence: Double, reason: String = "") {
        self.id = id
        self.date = date
        self.itemName = itemName
        self.category = category
        self.confidence = confidence
        self.reason = reason
    }
}
