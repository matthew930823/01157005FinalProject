import SwiftUI
import SwiftData
import Charts
import Lottie
import AVFoundation
import TipKit

class AudioManager: ObservableObject {
    var audioPlayer: AVAudioPlayer?
    
    func playSound(Sound:String) {
        if let soundURL = Bundle.main.url(forResource: Sound, withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.play()
            } catch {
                print("Error loading audio file: \(error.localizedDescription)")
            }
        }
    }
}
// Fortune 模型
@Model
final class Fortune {
    var money: Int
    var content: String
    var categoryIndex: Int
    var date: Date // 新增日期屬性
    var currency: String
    init(money: Int, content: String, categoryIndex: Int, date: Date,currency:String) {
        self.money = money
        self.content = content
        self.categoryIndex = categoryIndex
        self.date = date
        self.currency = currency
    }
}
struct LottieView: UIViewRepresentable {
    var name: String
    var loopMode: LottieLoopMode = .playOnce // 設定成 Lottie 提供的播放模式
    
    func makeUIView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView(name: name) // 創建動畫實例
        view.loopMode = loopMode
        view.play() // 播放動畫
        return view
    }
    
    func updateUIView(_ uiView: LottieAnimationView, context: Context) {}
}
struct SearchTip: Tip {
    var title: Text {
        Text("記帳紀錄")
    }
    
    var message: Text? {
        Text("使用搜尋功能快速尋找您的財務記錄。")
    }
    
    var image: Image? {
        Image(systemName: "magnifyingglass")
    }
}

let currencySymbols: [String: String] = [
    "USD": "$",    // 美元
    "EUR": "€",    // 歐元
    "TWD": "NT$",  // 新台幣
    "JPY": "¥",    // 日圓
    "CNY": "¥",    // 人民幣
]
struct FortuneView: View {
    @State private var showRecordSheet = false
    @State private var selectedFortune: Fortune?
    @State private var selectedIndex = 0 // 使用索引來表示選擇的日期
    @Query private var fortunes: [Fortune] // 查詢所有記錄
    
    @State private var listHeight: CGFloat = 200
    @State private var more = false
    
    @Environment(\.modelContext) private var context
    
    @State private var rippleLocation: CGPoint = .zero
    @State private var showRipple: Bool = false
    
    @State private var SecondGrade = false
    @State private var ThirdGrade = false
    
    @State private var currentIndex = 1
    @State private var scale: CGFloat = 1.0
    @State private var opacity: CGFloat = 1.0
    
    @State private var searchText = ""      // 搜尋文字
    
    @State private var searchPage = false
    @State private var showSuccessAnimation :Bool = false
    @State private var countFortuneAni : Int = 0
    
    @State private var audioManager = AudioManager()
    @State private var isEvolutionAnime : Bool = false
    
    private let searchTip = SearchTip()
    private var dates: [Date] {
        generateDates()
    }
    var body: some View {
        ZStack{
            ZStack{
                if(!searchPage){
                    FireEffect(index: currentIndex,scale: $scale,evolution: isEvolutionAnime, opacity: opacity)
                    if showSuccessAnimation {
                        LottieView(name: "success_checkmark", loopMode: .playOnce)
                            .frame(width: 100, height: 100)
                            .offset(y:-200)
                    }
                    
                }
                else{
                    TestView()
                }
                if(!isEvolutionAnime){
                    VStack {
                        HStack {
                            Spacer() // 將按鈕推到右側
                            Button(action: {
                                searchPage.toggle()
                            }) {
                                if(searchPage){
                                    Image(systemName: "pawprint")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.black)
                                        .padding()
                                        .overlay(
                                            Circle() // 添加一層圓形邊框
                                                .stroke(Color.black.opacity(0.3), lineWidth: 2)
                                        )
                                        .shadow(radius: 5)
                                }
                                else{
                                    Image(systemName:  "magnifyingglass")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(
                                            Circle() // 使用圓形作為背景
                                                .fill(RadialGradient(
                                                    gradient: Gradient(colors: [Color.brown, Color("LightWoodColor")]),
                                                    center: .center,
                                                    startRadius: 5,
                                                    endRadius: 70
                                                )
                                                )
                                                .overlay(
                                                    Circle() // 添加一層圓形邊框
                                                        .stroke(Color.black.opacity(0.3), lineWidth: 2) // 模擬木框效果
                                                )
                                        )
                                        .shadow(radius: 5)
                                        .popoverTip(searchTip, arrowEdge: .top)
                                }
                                
                            }
                        }
                        Spacer() // 將按鈕推到上側
                    }
                    .padding() // 控制與螢幕邊緣的間距
                }
                // 右上角的搜尋按鈕
                
                
            }
            if(!searchPage && !isEvolutionAnime){
                VStack {
                    Text("總帳數: \(fortunes.count)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color("LightWoodColor"), Color.brown]),
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black.opacity(0.2), lineWidth: 2)
                            )
                        )
                    
                    
                    Spacer()
                    VStack {
                        if(selectedIndex == 7){
                            Text("分類支出圓餅圖")
                                .font(.headline)
                                .foregroundColor(Color.white)
                                .padding(.bottom, 10)
                        }
                        else{
                            Text(dates[selectedIndex] == Date() ? "今天" : formatDate(dates[selectedIndex]))
                                .font(.headline)
                                .foregroundColor(Color.white)
                                .padding(.bottom, 10)
                        }
                        
                        // 日期選擇器（左右滑動）
                        TabView(selection: $selectedIndex) {
                            
                            ForEach(dates.indices.reversed(), id: \.self) { index in
                                VStack {
                                    List {
                                        ForEach(fortunes.filter { isSameDay($0.date, dates[index]) }) { fortune in
                                            HStack {
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
                                                .contentShape(Rectangle())
                                                .onTapGesture {
                                                    selectedFortune = fortune
                                                    showRecordSheet.toggle()
                                                }
                                                
                                                Button(action: {
                                                    deleteFortune(fortune)
                                                    countFortuneAni = fortunes.count
                                                }) {
                                                    Image(systemName: "trash")
                                                        .foregroundColor(.red)
                                                        .padding(8)
                                                }
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                }
                                .tag(index)
                            }
                            VStack {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text("收入:")
                                            .font(.headline)
                                        Spacer()
                                        Text("\(calculateTotalIncome(), format: .currency(code: "TWD"))")
                                            .font(.headline)
                                    }
                                    .padding(.vertical, 4)
                                    
                                    HStack {
                                        Text("支出:")
                                            .font(.headline)
                                        Spacer()
                                        Text("\(calculateTotalExpenditure(), format: .currency(code: "TWD"))")
                                            .font(.headline)
                                    }
                                    .padding(.vertical, 4)
                                    
                                    HStack {
                                        Text("收支:")
                                            .font(.headline)
                                        Spacer()
                                        let balance = calculateTotalIncome() - calculateTotalExpenditure()
                                        Text("\(balance, format: .currency(code: "TWD"))")
                                            .font(.headline)
                                            .foregroundColor(balance >= 0 ? .green : .red)
                                    }
                                    .padding(.vertical, 4)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(UIColor.systemGroupedBackground))
                                        .shadow(radius: 2)
                                )
                                .padding()
                                Chart {
                                    let categoryData = calculateCategoryTotals()
                                    ForEach(categoryData, id: \.category) { data in
                                        SectorMark(
                                            angle: .value("Amount", data.totalAmount),
                                            innerRadius: .ratio(0.5),  // 控制內圈半徑，調整成甜甜圈形狀
                                            outerRadius: .ratio(1.0)   // 控制外圈半徑
                                        )
                                        .foregroundStyle(categories[data.category].color.gradient)
                                        .annotation(position: .overlay) {
                                            Text(categories[data.category].name)
                                                .font(.caption)
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                                .frame(height: 300) // 圓餅圖的大小
                            }.tag(7)
                        }
                        .scrollContentBackground(.hidden)
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic)) // 使用 paging 樣式
                        .background(Color.black.opacity(0.1))
                        HStack {
                            // 新紀錄按鈕
                            Button(action: {
                                if (selectedIndex < 7) {
                                    selectedFortune = nil
                                    showRecordSheet.toggle()
                                    more = true
                                    withAnimation {
                                        listHeight = .infinity
                                    }
                                }
                            }) {
                                Text("＋新紀錄")
                                    .font(.title2)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(gradient: Gradient(colors: [Color.brown, Color("LightWoodColor")]),
                                                       startPoint: .topLeading,
                                                       endPoint: .bottomTrailing)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.black.opacity(0.2), lineWidth: 2) // 模擬木框效果
                                        )
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 20)
                            }
                            
                            Button(action: {
                                more.toggle()
                                withAnimation {
                                    listHeight = listHeight == 200 ? .infinity : 200
                                }
                                if fortunes.count > countFortuneAni && !more {
                                    countFortuneAni = fortunes.count
                                    withAnimation {
                                        showSuccessAnimation = true
                                        scale = 0.7
                                        audioManager.playSound(Sound: "pokemonlevelup")
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                            showSuccessAnimation = false
                                            withAnimation(.easeInOut(duration: 0.1)) {
                                                scale = 1
                                            }
                                            if fortunes.count >= 2 && !SecondGrade {
                                                // 進行動畫處理
                                                animateImages()
                                                SecondGrade = true
                                                // 播放音效
                                                audioManager.playSound(Sound: "pokemonevolutionsound")
                                            }
                                            else if fortunes.count >= 5 && SecondGrade && !ThirdGrade {
                                                // 進行動畫處理
                                                animateImages()
                                                ThirdGrade = true
                                                // 播放音效
                                                audioManager.playSound(Sound: "pokemonevolutionsound")
                                            }
                                        }
                                    }
                                }
                            }) {
                                Text(!more ? "顯示更多" : "顯示更少")
                                    .font(.title2)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(gradient: Gradient(colors: [Color("LightWoodColor"), Color.brown]),
                                                       startPoint: .topLeading,
                                                       endPoint: .bottomTrailing)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.black.opacity(0.2), lineWidth: 2)
                                        )
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 20)
                            }
                        }
                        
                    }
                    
                    .frame(maxWidth: .infinity, maxHeight: listHeight)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color("LightWoodColor"), Color.brown]),
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black.opacity(0.2), lineWidth: 2)
                        )
                    )
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .edgesIgnoringSafeArea(.bottom)
                }
                .sheet(isPresented: $showRecordSheet) {
                    FortuneRecord(fortune: selectedFortune, selectedDate: dates[selectedIndex], onAdd: { updatedFortune in
                        addFortune(updatedFortune)
                    }, close: {
                        closeSheet()
                    }).presentationDetents([.fraction(0.7)]) // 設置高度
                }
            }
            
        }.background(
            Image(.mainBG)
                .resizable()
                .scaledToFill()
                .opacity(0.5)
                .ignoresSafeArea())
    }
    private func animateImages() {
        let animationDuration: TimeInterval = 0.75
        let totalSteps = 22 // 設置步骤
        isEvolutionAnime = true
        if !SecondGrade{
            for step in 0..<totalSteps {
                DispatchQueue.main.asyncAfter(deadline: .now() + (animationDuration * Double(step))) {
                    withAnimation(.easeInOut(duration: animationDuration)) {
                        if step % 2 == 0 {
                            opacity = 0.5
                            scale = 1.5
                        } else {
                            opacity = 1
                            scale = 1.0
                            currentIndex = (currentIndex % 2) + 1
                        }
                    }
                    if step == totalSteps-1{
                        isEvolutionAnime = false
                    }
                }
            }
        }
        else{
            for step in 0..<totalSteps {
                DispatchQueue.main.asyncAfter(deadline: .now() + (animationDuration * Double(step))) {
                    withAnimation(.easeInOut(duration: animationDuration)) {
                        if step % 2 == 0 {
                            opacity = 0.5
                            scale = 1.5
                        } else {
                            opacity = 1
                            scale = 1.0
                            currentIndex = ((currentIndex+1) % 2) + 2
                        }
                    }
                    if step == totalSteps-1{
                        isEvolutionAnime = false
                    }
                }
            }
        }
    }
    // 新增或更新記錄
    private func addFortune(_ fortune: Fortune) {
        if let selectedFortune = selectedFortune {
            selectedFortune.money = fortune.money
            selectedFortune.content = fortune.content
            selectedFortune.categoryIndex = fortune.categoryIndex
            selectedFortune.date = dates[selectedIndex]
            selectedFortune.currency = fortune.currency
        } else {
            let newFortune = Fortune(money: fortune.money, content: fortune.content, categoryIndex: fortune.categoryIndex, date: dates[selectedIndex],currency: fortune.currency)
            context.insert(newFortune)
        }
        try? context.save() // 保存更改
        closeSheet()
    }
    
    // 刪除記錄
    private func deleteFortune(_ fortune: Fortune) {
        context.delete(fortune)
        try? context.save() // 保存更改
    }
    
    // 關閉表單
    private func closeSheet() {
        showRecordSheet = false
    }
    
    // 生成過去 7 天的日期
    private func generateDates() -> [Date] {
        var dates: [Date] = []
        for i in 0..<7 {
            if let date = Calendar.current.date(byAdding: .day, value: -i, to: Date()) {
                dates.append(date)
            }
        }
        return dates
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
    
    private func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date1, inSameDayAs: date2)
    }
    
    // 計算每個分類的金額總和
    private func calculateCategoryTotals() -> [(category: Int, totalAmount: Double)] {
        var totals: [Int: Double] = [:]
        
        for fortune in fortunes {
            let category = fortune.categoryIndex
            totals[category, default: 0] += Double(fortune.money)/exchangeRates[fortune.currency]!*exchangeRates["TWD"]!
        }
        
        return totals.filter { $0.key != 9 } // 排除收入分類
            .map { (category: $0.key, totalAmount: $0.value) }
    }
    
    // 計算總支出，排除收入分類
    private func calculateTotalExpenditure() -> Double {
        fortunes
            .filter { $0.categoryIndex != 9 } // 排除收入分類
            .reduce(0) { $0 + Double($1.money)/exchangeRates[$1.currency]!*exchangeRates["TWD"]! }
    }
    // 計算總收入
    private func calculateTotalIncome() -> Double {
        fortunes
            .filter { $0.categoryIndex == 9 } // 收入分類
            .reduce(0) { $0 + Double($1.money)/exchangeRates[$1.currency]!*exchangeRates["TWD"]! }
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
    FortuneView()
        .modelContainer(for: Fortune.self, inMemory: true)
        .task {
            try? Tips.resetDatastore()
            
            try? Tips.configure([
                .displayFrequency(.immediate),
                .datastoreLocation(.applicationDefault)
            ])
        }
}
