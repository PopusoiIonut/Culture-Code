import Foundation
import SwiftUI

enum RuleCategory: String, Codable, CaseIterable {
    case illegal = "Illegal"
    case etiquette = "Etiquette"
    case clothing = "Clothing"
    case photography = "Photography"
    case internet = "Internet & Comm"
    
    var color: Color {
        switch self {
        case .illegal: return .red
        case .etiquette: return .orange
        case .clothing: return .purple
        case .photography: return .blue
        case .internet: return .teal
        }
    }
    
    var icon: String {
        switch self {
        case .illegal: return "hand.raised.slash.fill"
        case .etiquette: return "person.2.fill"
        case .clothing: return "tshirt.fill"
        case .photography: return "camera.badge.ellipsis"
        case .internet: return "wifi.slash"
        }
    }
}

struct Rule: Codable, Identifiable {
    var id: UUID = UUID()
    let title: String
    let description: String
    let category: RuleCategory
    let severity: String // e.g. "Fine up to $10,000", "Socially Frowned Upon"
    
    enum CodingKeys: String, CodingKey {
        case title, description, category, severity
    }
}
