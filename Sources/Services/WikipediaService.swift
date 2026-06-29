import Foundation

class WikipediaService {
    
    struct WikipediaResponse: Codable {
        let query: WikipediaQuery?
    }

    struct WikipediaQuery: Codable {
        let pages: [String: WikipediaPage]?
    }

    struct WikipediaPage: Codable {
        let pageid: Int?
        let title: String?
        let extract: String?
    }
    
    /// Fetches relevant country/etiquette content from Wikipedia using a fallback sequence.
    /// Returns the fetched plain text extract and the matching Wikipedia web URL.
    static func fetchWikipediaContent(for countryName: String) async -> (text: String, url: String) {
        let cleanName = countryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty else { return ("", "") }
        
        let titlesToTry = [
            "Etiquette in \(cleanName)",
            "Culture of \(cleanName)",
            cleanName
        ]
        
        for title in titlesToTry {
            if let extract = await fetchWikipediaArticle(title: title), !extract.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let urlFriendlyTitle = title
                    .replacingOccurrences(of: " ", with: "_")
                    .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? title
                let webUrl = "https://en.wikipedia.org/wiki/\(urlFriendlyTitle)"
                return (extract, webUrl)
            }
        }
        
        // Final fallback: return empty if nothing could be fetched
        return ("", "")
    }
    
    private static func fetchWikipediaArticle(title: String) async -> String? {
        guard let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://en.wikipedia.org/w/api.php?action=query&format=json&prop=extracts&explaintext=1&titles=\(encodedTitle)&redirects=1") else {
            return nil
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return nil
            }
            
            let decoder = JSONDecoder()
            let wikiResponse = try decoder.decode(WikipediaResponse.self, from: data)
            
            guard let pages = wikiResponse.query?.pages else {
                return nil
            }
            
            for (key, page) in pages {
                // Wikipedia API returns a "-1" key if page doesn't exist
                if key == "-1" {
                    continue
                }
                if let extract = page.extract, !extract.isEmpty {
                    return extract
                }
            }
        } catch {
            print("Failed to fetch/decode Wikipedia page '\(title)': \(error.localizedDescription)")
        }
        
        return nil
    }
}
