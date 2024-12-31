import SwiftUI
import SwiftData

struct TestView: View {
    @Query private var fortunes: [Fortune] // 查詢所有記錄
    @State private var searchText = ""      // 搜尋文字
    
    var body: some View {
        NavigationStack {
            VStack {
                if filteredFortunes.isEmpty {
                    ContentUnavailableView("找不到符合條件的記錄", systemImage: "magnifyingglass")
                        .padding()
                } else {
                    List {
                        ForEach(filteredFortunes) { fortune in
                            HStack{
                                Image(systemName: categories[fortune.categoryIndex].icon)
                                    .foregroundColor(categories[fortune.categoryIndex].color)
                                VStack(alignment: .leading) {
                                    Text("\(fortune.currency) \(currencySymbols[fortune.currency] ?? "")\(fortune.money) - \(fortune.content)")
                                        .font(.headline)
                                    Text(formatDate(fortune.date))
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "搜尋記帳內容或分類") // 搜尋框
            .navigationTitle("記帳記錄") // 設定標題
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
    
    private var filteredFortunes: [Fortune] {
        if searchText.isEmpty {
            return fortunes
        } else {
            return fortunes.filter { fortune in
                fortune.content.localizedCaseInsensitiveContains(searchText) ||
                categories[fortune.categoryIndex].name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

#Preview {
    TestView().modelContainer(for: Fortune.self, inMemory: true)
}
