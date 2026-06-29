import SwiftUI

struct CountriesListView: View {
    @State private var allCountries: [Country] = []
    @State private var searchText = ""
    @State private var isSearchingOnline = false
    @State private var searchError: String? = nil
    
    var filteredCountries: [Country] {
        if searchText.isEmpty {
            return allCountries
        }
        return allCountries.filter { $0.name.lowercased().contains(searchText.lowercased()) }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(filteredCountries) { country in
                        NavigationLink(destination: CountryDetailView(country: country)) {
                            HStack(spacing: 16) {
                                Text(country.flagEmoji)
                                    .font(.system(size: 40))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(country.name)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                    Text("\(country.rules.count) Known Laws & Rules")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    
                    if !searchText.isEmpty && filteredCountries.isEmpty {
                        VStack(spacing: 16) {
                            Text("No offline data for '\(searchText)'")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                searchOnline()
                            }) {
                                HStack {
                                    Image(systemName: "magnifyingglass.circle.fill")
                                    Text("Search Online & Download")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.accentColor)
                                .cornerRadius(12)
                            }
                            .padding(.top, 8)
                        }
                        .padding(.vertical, 32)
                        .listRowBackground(Color.clear)
                    }
                }
                
                if isSearchingOnline {
                    Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        Text("Generating Database...")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding(32)
                    .background(Color(UIColor.systemBackground).opacity(0.2))
                    .background(BlurView(style: .systemThinMaterialDark))
                    .cornerRadius(16)
                }
            }
            .navigationTitle("CultureCode")
            .searchable(text: $searchText, prompt: "Search destinations...")
            .onAppear {
                refreshData()
            }
            .alert(isPresented: Binding<Bool>(
                get: { searchError != nil },
                set: { if !$0 { searchError = nil } }
            )) {
                Alert(
                    title: Text("Download Failed"),
                    message: Text(searchError ?? ""),
                    dismissButton: .default(Text("OK")) { searchError = nil }
                )
            }
        }
    }
    
    private func refreshData() {
        allCountries = DataLoader.loadCountries()
    }
    
    private func searchOnline() {
        guard !searchText.isEmpty else { return }
        isSearchingOnline = true
        searchError = nil
        
        Task {
            do {
                let newCountry = try await NetworkManager.fetchCountryRules(for: searchText)
                
                // Save it locally
                DataLoader.saveDownloadedCountry(newCountry)
                
                DispatchQueue.main.async {
                    self.refreshData()
                    self.searchText = ""
                    self.isSearchingOnline = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.isSearchingOnline = false
                    self.searchError = error.localizedDescription
                }
            }
        }
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView { return UIVisualEffectView(effect: UIBlurEffect(style: style)) }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
