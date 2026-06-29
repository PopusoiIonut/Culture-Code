import SwiftUI

struct RuleCardView: View {
    let rule: Rule
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: rule.category.icon)
                    .foregroundColor(rule.category.color)
                    .font(.title2)
                
                Text(rule.category.rawValue.uppercased())
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(rule.category.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(rule.category.color.opacity(0.15))
                    .cornerRadius(8)
                
                Spacer()
                
                if !rule.severity.isEmpty {
                    Text(rule.severity)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(8)
                }
            }
            
            Text(rule.title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(rule.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
