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
    case noAPIKey
    case imageEncodingFailed
    case networkError(Error)
    case invalidResponse(Int)
    case lowConfidence(WasteResult)
    case parseError(String)

    var errorDescription: String? {
        switch self {
        case .noAPIKey:                  return "API key not set. Add it in AIService.swift."
        case .imageEncodingFailed:       return "Could not encode the image."
        case .networkError(let e):       return "Network error: \(e.localizedDescription)"
        case .invalidResponse(let code): return "API returned status \(code)."
        case .lowConfidence:             return "Image not clear enough. Move closer and try again."
        case .parseError(let msg):       return "Parse error: \(msg)"
        }
    }
}

final class AIService {
    static let shared = AIService()
    private init() {}

    // Set your Anthropic API key here — NEVER commit this to source control.
    private let apiKey = "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"
    private let endpoint = URL(string: "https://api.anthropic.com/v1/messages")!

    func classify(image: UIImage) async throws -> WasteResult {
        guard !apiKey.isEmpty, apiKey != "YOUR_ANTHROPIC_API_KEY" else {
            throw AIError.noAPIKey
        }

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw AIError.imageEncodingFailed
        }

        let base64 = imageData.base64EncodedString()

        let prompt = """
        You are a waste sorting assistant for California, following SB 1383 guidelines.
        Analyze the image and identify the primary waste item.

        California-specific rules:
        - Greasy pizza boxes → COMPOST (not RECYCLE)
        - Plastic bags → TRASH (not RECYCLE)
        - Food-soiled paper or cardboard → COMPOST
        - Clean cardboard and paper → RECYCLE
        - Glass bottles and jars → RECYCLE
        - Food scraps and yard waste → COMPOST
        - Styrofoam → TRASH
        - Electronics → TRASH (needs special recycling)

        Respond ONLY with valid JSON, no other text:
        {
          "item": "descriptive item name",
          "category": "RECYCLE",
          "confidence": 0.95,
          "reason": "One sentence explaining why.",
          "tip": "One helpful disposal tip."
        }

        category must be exactly one of: RECYCLE, COMPOST, TRASH
        confidence is 0.0–1.0. If unclear, set confidence below 0.6.
        """

        let body: [String: Any] = [
            "model": "claude-opus-4-8",
            "max_tokens": 400,
            "messages": [[
                "role": "user",
                "content": [
                    ["type": "image",
                     "source": ["type": "base64",
                                "media_type": "image/jpeg",
                                "data": base64]],
                    ["type": "text", "text": prompt]
                ]
            ]]
        ]

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json",  forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey,              forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01",        forHTTPHeaderField: "anthropic-version")
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

        guard
            let json    = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let content = json["content"] as? [[String: Any]],
            let text    = content.first?["text"] as? String,
            let start   = text.firstIndex(of: "{"),
            let end     = text.lastIndex(of: "}")
        else {
            throw AIError.parseError("Unexpected API response shape")
        }

        let jsonString = String(text[start...end])
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw AIError.parseError("Could not re-encode JSON substring")
        }

        let result = try JSONDecoder().decode(WasteResult.self, from: jsonData)

        if result.confidence < 0.75 {
            throw AIError.lowConfidence(result)
        }

        return result
    }
}
