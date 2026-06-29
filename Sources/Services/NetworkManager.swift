import Foundation

class NetworkManager {
    // Get a free API key from Google AI Studio: https://aistudio.google.com/
    // Place your key below.
    static let geminiKey = "YOUR_FREE_GEMINI_API_KEY"
    
    enum NetworkError: LocalizedError {
        case invalidURL
        case invalidResponse
        case decodingError
        case noData
        case apiError(String)
        
        var errorDescription: String? {
            switch self {
            case .invalidURL: return "The server URL is invalid. Please contact support."
            case .invalidResponse: return "Received an invalid response from the server."
            case .decodingError: return "Failed to process the data from the server."
            case .noData: return "No data was returned from the server."
            case .apiError(let message): return message
            }
        }
    }
    
    static func fetchCountryRules(for countryName: String) async throws -> Country {
        guard geminiKey != "YOUR_FREE_GEMINI_API_KEY" && !geminiKey.isEmpty else {
            throw NetworkError.apiError("Please configure your free Gemini API Key in NetworkManager.swift first.")
        }
        
        guard let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=\(geminiKey)") else {
            throw NetworkError.invalidURL
        }
        
        // Fetch Wikipedia content for grounding
        let (wikipediaText, wikiUrl) = await WikipediaService.fetchWikipediaContent(for: countryName)
        
        let systemPrompt = """
        You are a travel law and etiquette expert. The user will provide a country name and optional Wikipedia text content. 
        You must return ONLY a raw, valid JSON object (no markdown, no backticks, no extra text) matching this EXACT schema:
        {
          "name": "Country Name",
          "isoCode": "2-letter ISO code",
          "flagEmoji": "Country Flag Emoji",
          "bannerColorHex": "A 6-character hex color code representing the flag",
          "rules": [
            {
              "title": "Rule Title",
              "description": "Detailed description of the rule.",
              "category": "Must be one of: Illegal, Etiquette, Clothing, Photography, Internet & Comm",
              "severity": "E.g., Jail, Fined, Frowned Upon"
            }
          ]
        }
        Provide 3-5 of the most uncommon, surprising, or strict laws/etiquette rules for that country.
        If Wikipedia reference text is provided, prioritize extracting and synthesizing the rules from that text. If it is empty or does not contain specific rules, use your own expert knowledge of that country's laws and customs.
        """
        
        var userText = "Country: \(countryName)"
        if !wikipediaText.isEmpty {
            userText += "\n\nWikipedia Reference Text:\n\(wikipediaText.prefix(15000))"
        }
        
        let parameters: [String: Any] = [
            "contents": [
                [
                    "role": "user",
                    "parts": [
                        ["text": userText]
                    ]
                ]
            ],
            "systemInstruction": [
                "parts": [
                    ["text": systemPrompt]
                ]
            ],
            "generationConfig": [
                "responseMimeType": "application/json",
                "temperature": 0.3
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw NetworkError.apiError("AI Service Error (Status \(statusCode)). Check your Gemini API key configuration.")
        }
        
        guard let jsonResult = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = jsonResult["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let contentString = firstPart["text"] as? String else {
            throw NetworkError.invalidResponse
        }
        
        var cleanJSONString = contentString.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanJSONString.hasPrefix("```json") {
            cleanJSONString = cleanJSONString.replacingOccurrences(of: "```json", with: "")
            cleanJSONString = cleanJSONString.replacingOccurrences(of: "```", with: "")
            cleanJSONString = cleanJSONString.trimmingCharacters(in: .whitespacesAndNewlines)
        } else if cleanJSONString.hasPrefix("```") {
            cleanJSONString = cleanJSONString.replacingOccurrences(of: "```", with: "")
            cleanJSONString = cleanJSONString.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        guard let jsonData = cleanJSONString.data(using: .utf8) else {
            throw NetworkError.noData
        }
        
        do {
            let decoder = JSONDecoder()
            let decodedCountry = try decoder.decode(Country.self, from: jsonData)
            
            // Reconstruct Country object populated with the source wikiUrl
            let country = Country(
                id: decodedCountry.id,
                name: decodedCountry.name,
                isoCode: decodedCountry.isoCode,
                flagEmoji: decodedCountry.flagEmoji,
                bannerColorHex: decodedCountry.bannerColorHex,
                rules: decodedCountry.rules,
                wikiUrl: wikiUrl.isEmpty ? nil : wikiUrl
            )
            return country
        } catch {
            print("Decoding Error: \(error)")
            throw NetworkError.decodingError
        }
    }
}
