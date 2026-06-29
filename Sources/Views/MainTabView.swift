import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            CountriesListView()
                .tabItem {
                    Label("Countries", systemImage: "globe.europe.africa.fill")
                }
            
            SafeConnectView()
                .tabItem {
                    Label("Safe Connect", systemImage: "network.badge.shield.half.filled")
                }
        }
        .tint(.accentColor)
    }
}
