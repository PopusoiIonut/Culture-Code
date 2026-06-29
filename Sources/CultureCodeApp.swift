import SwiftUI

@main
struct CultureCodeApp: App {
    @AppStorage("isOnboardingComplete") var isOnboardingComplete: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if isOnboardingComplete {
                MainTabView()
            } else {
                OnboardingView(isOnboardingComplete: $isOnboardingComplete)
            }
        }
    }
}
