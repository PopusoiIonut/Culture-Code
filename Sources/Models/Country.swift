import Foundation

struct Country: Codable, Identifiable {
    var id: UUID = UUID()
    let name: String
    let isoCode: String // e.g. "AE", "SG", "JP"
    let flagEmoji: String
    let bannerColorHex: String
    let rules: [Rule]
    let wikiUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case name, isoCode, flagEmoji, bannerColorHex, rules, wikiUrl
    }
    
    init(id: UUID = UUID(), name: String, isoCode: String, flagEmoji: String, bannerColorHex: String, rules: [Rule], wikiUrl: String? = nil) {
        self.id = id
        self.name = name
        self.isoCode = isoCode
        self.flagEmoji = flagEmoji
        self.bannerColorHex = bannerColorHex
        self.rules = rules
        self.wikiUrl = wikiUrl
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.isoCode = try container.decode(String.self, forKey: .isoCode)
        self.flagEmoji = try container.decode(String.self, forKey: .flagEmoji)
        self.bannerColorHex = try container.decode(String.self, forKey: .bannerColorHex)
        self.rules = try container.decode([Rule].self, forKey: .rules)
        self.wikiUrl = try container.decodeIfPresent(String.self, forKey: .wikiUrl)
    }
}
