import SwiftUI

struct SafeConnectView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Safe Connection Checklist")) {
                    ChecklistItem(title: "VPN is Active", subtitle: "Always route traffic through a trusted VPN.", isChecked: true)
                    ChecklistItem(title: "HTTPS Everywhere", subtitle: "Never enter passwords on HTTP sites.", isChecked: true)
                    ChecklistItem(title: "Avoid Open Networks", subtitle: "If it doesn't have a password, it's not safe.", isChecked: false)
                }
                
                Section(header: Text("Universally Trusted WiFi Havens")) {
                    WiFiHavenRow(icon: "applelogo", name: "Official Apple Stores", description: "Highly monitored, secure enterprise networks.")
                    WiFiHavenRow(icon: "building.2.fill", name: "Major Hotel Chains", description: "Look for Marriott/Hilton login portals (use VPN).")
                    WiFiHavenRow(icon: "airplane.departure", name: "Premium Airport Lounges", description: "Safer than the free public airport network.")
                }
                
                Section(header: Text("Global Internet Warnings")) {
                    Text("⚠️ **UAE:** Using a VPN to access blocked VoIP (WhatsApp/FaceTime) is illegal.")
                        .font(.footnote)
                    Text("⚠️ **China:** The Great Firewall blocks Google, Meta, and most Western news. You must install a specialized VPN *before* arriving.")
                        .font(.footnote)
                }
            }
            .navigationTitle("Safe Connect")
            .listStyle(InsetGroupedListStyle())
        }
    }
}

struct ChecklistItem: View {
    let title: String
    let subtitle: String
    let isChecked: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isChecked ? .green : .gray)
                .font(.title2)
            
            VStack(alignment: .leading) {
                Text(title).font(.headline)
                Text(subtitle).font(.caption).foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct WiFiHavenRow: View {
    let icon: String
    let name: String
    let description: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 30)
                .font(.title2)
                .foregroundColor(.accentColor)
            
            VStack(alignment: .leading) {
                Text(name).font(.headline)
                Text(description).font(.caption).foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
