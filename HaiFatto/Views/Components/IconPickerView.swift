// Hai fatto? — IconPickerView
import SwiftUI

struct IconCategory: Identifiable {
    let id = UUID()
    let name: String
    let icons: [String]
}

struct IconPickerView: View {
    @Binding var selectedIcon: String
    @Environment(\.dismiss) var dismiss
    @State var searchText: String = ""
    
    let categories: [IconCategory] = [
        IconCategory(name: String(localized: "Daily"), icons: ["sun.max", "moon", "bed.double", "alarm", "cup.and.saucer", "fork.knife", "pills"]),
        IconCategory(name: String(localized: "Health"), icons: ["heart", "figure.walk", "figure.run", "dumbbell", "drop", "brain", "lungs"]),
        IconCategory(name: String(localized: "Work"), icons: ["briefcase", "laptopcomputer", "book", "pencil", "envelope", "phone", "calendar"]),
        IconCategory(name: String(localized: "Home"), icons: ["house", "washer", "trash", "leaf", "pawprint", "cart", "bag"]),
        IconCategory(name: String(localized: "Wellness"), icons: ["face.smiling", "sparkles", "star", "hands.sparkles", "cross", "bandage"]),
        IconCategory(name: String(localized: "Finance"), icons: ["dollarsign.circle", "creditcard", "banknote", "chart.line.uptrend.xyaxis"]),
        IconCategory(name: String(localized: "Social"), icons: ["person.2", "bubble.left", "hand.wave", "gift", "party.popper"]),
        IconCategory(name: String(localized: "Custom"), icons: ["checkmark.circle", "flag", "bell", "bolt", "gear", "paintbrush"])
    ]
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 5)
    
    var filteredCategories: [IconCategory] {
        if searchText.isEmpty {
            return categories
        }
        
        return categories.compactMap { category in
            let filteredIcons = category.icons.filter { $0.localizedCaseInsensitiveContains(searchText) }
            if filteredIcons.isEmpty { return nil }
            return IconCategory(name: category.name, icons: filteredIcons)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 24) {
                    ForEach(filteredCategories) { category in
                        Section {
                            ForEach(category.icons, id: \.self) { icon in
                                Button {
                                    selectedIcon = icon
                                    dismiss()
                                } label: {
                                    Image(systemName: icon)
                                        .font(.title2)
                                        .frame(width: 44, height: 44)
                                        .background(
                                            Circle()
                                                .fill(selectedIcon == icon ? Color.accentColor.opacity(0.2) : Color.clear)
                                        )
                                        .foregroundStyle(selectedIcon == icon ? Color.accentColor : Color.primary)
                                }
                                .buttonStyle(.plain)
                            }
                        } header: {
                            Text(category.name)
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 8)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(String(localized: "Select Icon"))
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: String(localized: "Search icons"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) {
                        dismiss()
                    }
                }
            }
        }
    }
}
