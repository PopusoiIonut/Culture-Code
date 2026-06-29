import SwiftUI

struct CountryDetailView: View {
    let country: Country
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                ZStack {
                    Color(hex: country.bannerColorHex)
                        .frame(height: 150)
                        .opacity(0.8)
                    
                    VStack {
                        Text(country.flagEmoji)
                            .font(.system(size: 60))
                            .shadow(radius: 5)
                        Text(country.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .shadow(radius: 2)
                    }
                    
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: shareCountry) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(Color.black.opacity(0.3))
                                    .clipShape(Circle())
                            }
                        }
                        Spacer()
                    }
                    .padding()
                }
                .cornerRadius(16)
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Rules
                VStack(spacing: 16) {
                    ForEach(country.rules) { rule in
                        RuleCardView(rule: rule)
                    }
                }
                .padding(.horizontal)
                
                if let wikiUrl = country.wikiUrl, let url = URL(string: wikiUrl) {
                    Link(destination: url) {
                        HStack(spacing: 8) {
                            Image(systemName: "book.fill")
                            Text("Read more on Wikipedia")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.accentColor)
                                .shadow(color: Color.accentColor.opacity(0.3), radius: 6, x: 0, y: 3)
                        )
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                
                Spacer()
                    .frame(height: 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
    }
    
    private func shareCountry() {
        let text = "Check out these uncommon rules for \(country.name) on CultureCode! 🌍⚖️"
        let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(av, animated: true, completion: nil)
        }
    }
}

// Helper for Hex Colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
