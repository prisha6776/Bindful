import Foundation

struct ScanRecord: Identifiable, Codable {
    let id: UUID
    let date: Date
    let itemName: String
    let category: WasteCategory
    let confidence: Double
    let reason: String
    var userCorrection: WasteCategory?

    init(id: UUID = UUID(), date: Date = Date(), itemName: String,
         category: WasteCategory, confidence: Double, reason: String = "",
         userCorrection: WasteCategory? = nil) {
        self.id = id
        self.date = date
        self.itemName = itemName
        self.category = category
        self.confidence = confidence
        self.reason = reason
        self.userCorrection = userCorrection
    }
}
