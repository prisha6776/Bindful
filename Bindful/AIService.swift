import Foundation
import UIKit

enum WasteCategory: String, Codable, CaseIterable {
    case recycle = "RECYCLE"
    case compost = "COMPOST"
    case trash   = "TRASH"

    var displayName: String { rawValue.capitalized }

    var sfSymbol: String {
        switch self {
        case .recycle: return "arrow.3.trianglepath"
        case .compost: return "leaf.fill"
        case .trash:   return "trash.fill"
        }
    }

    var hexColor: String {
        switch self {
        case .recycle: return "#2196F3"
        case .compost: return "#4CAF50"
        case .trash:   return "#9E9E9E"
        }
    }
}

struct WasteResult: Codable {
    let item: String
    let category: WasteCategory
    let confidence: Double
    let reason: String
    let tip: String
}

enum AIError: LocalizedError {
    case imageEncodingFailed
    case networkError(Error)
    case invalidResponse(Int)
    case lowConfidence
    case parseError(String)

    var errorDescription: String? {
        switch self {
        case .imageEncodingFailed:       return "Could not encode the image."
        case .networkError(let e):       return "Network error: \(e.localizedDescription)"
        case .invalidResponse(let code): return "Server returned status \(code)."
        case .lowConfidence:             return "Image not clear enough. Move closer and try again."
        case .parseError(let msg):       return "Parse error: \(msg)"
        }
    }
}

final class AIService {
    static let shared = AIService()
    private init() {}

    // My backend server holds the real API key, so the app itself never has it
    private let endpoint = URL(string: "https://bindful-api.vercel.app/api/classify")!

    // A random ID for this install so the backend can count scans anonymously
    private func getDeviceId() -> String {
        let key = "ecolens.anonymousDeviceId"
        if let existing = UserDefaults.standard.string(forKey: key) {
            return existing
        }
        let newId = UUID().uuidString
        UserDefaults.standard.set(newId, forKey: key)
        return newId
    }

    func classifyMultiple(image: UIImage) async throws -> [WasteResult] {
        // turn the photo into base64 text so it can go in a JSON request
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw AIError.imageEncodingFailed
        }
        let base64 = imageData.base64EncodedString()

        let body: [String: Any] = [
            "image": base64,
            "multi": true,
            "deviceId": getDeviceId()
        ]

        // send it to my backend, which does the actual AI call
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw AIError.networkError(error)
        }

        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            throw AIError.invalidResponse(http.statusCode)
        }

        // decode the list of items the backend found
        struct MultiResponse: Decodable { let items: [WasteResult] }
        let parsed: MultiResponse
        do {
            parsed = try JSONDecoder().decode(MultiResponse.self, from: data)
        } catch {
            throw AIError.parseError("Unexpected server response shape")
        }

        // drop anything the AI wasn't confident about
        let filtered = parsed.items.filter { $0.confidence >= 0.5 }
        guard !filtered.isEmpty else {
            throw AIError.lowConfidence
        }
        return filtered
    }
}
