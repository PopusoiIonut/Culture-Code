import Foundation

class DataLoader {
    private static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    private static let savedCountriesURL = documentsDirectory.appendingPathComponent("SavedCountries.json")
    
    static func loadCountries() -> [Country] {
        var allCountries: [Country] = []
        
        // 1. Load Hardcoded Offline Database
        if let url = Bundle.main.url(forResource: "CultureDatabase", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let bundledCountries = try decoder.decode([Country].self, from: data)
                allCountries.append(contentsOf: bundledCountries)
            } catch {
                print("Failed to decode CultureDatabase.json: \(error)")
            }
        } else {
            print("CultureDatabase.json not found in bundle.")
        }
        
        // 2. Load User Downloaded Countries
        do {
            let data = try Data(contentsOf: savedCountriesURL)
            let decoder = JSONDecoder()
            let downloadedCountries = try decoder.decode([Country].self, from: data)
            allCountries.append(contentsOf: downloadedCountries)
        } catch {
            print("No downloaded countries found or failed to load: \(error.localizedDescription)")
        }
        
        // Return sorted, unique by name
        var uniqueCountries = [String: Country]()
        for country in allCountries {
            uniqueCountries[country.name.lowercased()] = country
        }
        
        return Array(uniqueCountries.values).sorted { $0.name < $1.name }
    }
    
    static func saveDownloadedCountry(_ country: Country) {
        // Load existing
        var downloaded: [Country] = []
        if let data = try? Data(contentsOf: savedCountriesURL),
           let existing = try? JSONDecoder().decode([Country].self, from: data) {
            downloaded = existing
        }
        
        // Avoid duplicates
        if !downloaded.contains(where: { $0.name.lowercased() == country.name.lowercased() }) {
            downloaded.append(country)
            
            // Save
            do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                let data = try encoder.encode(downloaded)
                try data.write(to: savedCountriesURL)
                print("Successfully saved \(country.name) to offline storage.")
            } catch {
                print("Failed to save downloaded country: \(error)")
            }
        }
    }
}
