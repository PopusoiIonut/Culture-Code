import SwiftUI

struct OnboardingView: View {
    @Binding var isOnboardingComplete: Bool
    @State private var currentPage = 0
    
    let pages = [
        OnboardingPage(
            title: "Travel with Confidence",
            description: "CultureCode is your silent guardian, keeping you aware of uncommon laws and etiquette rules wherever you go.",
            image: "globe.americas.fill",
            color: .accentColor
        ),
        OnboardingPage(
            title: "100% Offline Access",
            description: "No internet? No problem. Our entire core database of rules is stored locally on your device for instant access anywhere.",
            image: "wifi.slash",
            color: .orange
        ),
        OnboardingPage(
            title: "Connect Safely",
            description: "Use our Safe Connect hub to find trusted WiFi havens and follow our safety checklists to protect your digital identity.",
            image: "network.badge.shield.half.filled",
            color: .teal
        )
    ]
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                HStack {
                    Spacer()
                    Button("Skip") {
                        isOnboardingComplete = true
                    }
                    .foregroundColor(.secondary)
                    .padding()
                }
                
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        VStack(spacing: 20) {
                            Image(systemName: pages[index].image)
                                .font(.system(size: 80))
                                .foregroundColor(pages[index].color)
                                .padding(.bottom, 20)
                            
                            Text(pages[index].title)
                                .font(.title)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            Text(pages[index].description)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                
                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        isOnboardingComplete = true
                    }
                }) {
                    Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(12)
                        .padding(.horizontal, 40)
                }
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let image: String
    let color: Color
}
