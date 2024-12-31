//
//  FortuneList.swift
//  01157005FinalProject
//
//  Created by user11 on 2024/11/27.
//

import SwiftUI
import SwiftData
struct Category {
    var name: String
    var icon: String
    var color: Color
}
let categories: [Category] = [
    Category(name: "食物", icon: "fork.knife", color: .orange),
    Category(name: "飲品", icon: "cup.and.saucer", color: .purple),
    Category(name: "交通", icon: "car.fill", color: .blue),
    Category(name: "消費", icon: "creditcard.fill", color: .green),
    Category(name: "娛樂", icon: "tv.fill", color: .red),
    Category(name: "居家", icon: "house.fill", color: .brown),
    Category(name: "３Ｃ", icon: "desktopcomputer", color: .cyan),
    Category(name: "醫藥", icon: "pills", color: .mint),
    Category(name: "其他", icon: "ellipsis.circle.fill", color: .gray),
    Category(name: "收入", icon: "dollarsign.circle", color: .yellow)
]
var exchangeRates: [String: Double] = ["USD": 1.0,"EUR": 0.9447901286,"CNY": 7.2579811079,"JPY": 150.2108696759,"TWD": 32.5]
struct FortuneRecord: View {
    var fortune: Fortune?
    @State private var newMoney = ""
    @State private var newContent = ""
    @State private var selectedCategoryIndex = 0
    @State private var selectedCurrency = "USD"
    
    
    @State private var targetCurrency: String = "EUR"
    @State private var convertedAmount: Int?
    
    var selectedDate = Date() // 新增的日期屬性
    var onAdd: (Fortune) -> Void
    var close: () -> Void

    let currencies = ["USD", "EUR", "TWD", "JPY", "CNY"] // 支援的貨幣種類

    var body: some View {
        VStack {
            Text("紀錄")
                .font(.headline)

            TextField("輸入金額", text: $newMoney)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: newMoney) {
                    convertCurrency()
                }

            TextField("輸入內容", text: $newContent)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            // 貨幣選擇
            Picker("選擇貨幣", selection: $selectedCurrency) {
                ForEach(currencies, id: \.self) { currency in
                    Text(currency)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .onChange(of: selectedCurrency) {
                convertCurrency()
            }
            // 轉換貨幣選擇
            Picker("選擇轉換貨幣", selection: $targetCurrency) {
                ForEach(currencies, id: \.self) { currency in
                    Text(currency)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .onChange(of: targetCurrency) {
                convertCurrency()
            }
            Text("轉換後:\(targetCurrency) : \(String(format: "%d", convertedAmount ?? 0))")

            // 類別選擇
            VStack(alignment: .leading) {
                Text("選擇類別")
                    .font(.headline)
                    .foregroundColor(.gray)

                Picker("選擇類別", selection: $selectedCategoryIndex) {
                    ForEach(categories.indices, id: \.self) { index in
                        HStack {
                            Image(systemName: categories[index].icon)
                                .foregroundColor(categories[index].color)
                            Text(categories[index].name)
                        }
                        .tag(index)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 10)
                .padding()
            }

            HStack {
                Button("取消") {
                    close()
                }
                .padding()

                Button("加入") {
                    if let money = convertedAmount , !newContent.isEmpty {
                        let fortune = Fortune(
                            money: money,
                            content: newContent,
                            categoryIndex: selectedCategoryIndex,
                            date: selectedDate,
                            currency: targetCurrency
                        )
                        onAdd(fortune)
                        close()
                    }
                }
                .padding()
            }
        }
        .padding()
        .onAppear {
            if let fortune = fortune {
                newMoney = "\(fortune.money)"
                newContent = fortune.content
                selectedCategoryIndex = fortune.categoryIndex
                selectedCurrency = fortune.currency
            }
            if exchangeRates.isEmpty{
                //fetchCurrencyRates()
            }
        }
    }
    func fetchCurrencyRates() {
        let apiKey = "fca_live_6sSXCnferUx192AtbVZWJgDY7O01hoaAu4aSQc0d"
        let urlStr = "https://api.freecurrencyapi.com/v1/latest?apikey=\(apiKey)"
        
        URLSession.shared.dataTask(with: URL(string: urlStr)!) { data, response, error in
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let result = json["data"] as? [String: Any] {
                        
                        let rates = result.compactMapValues { value in
                            if let rate = value as? Double {
                                return rate
                            } else if let rateString = value as? String, let rate = Double(rateString) {
                                return rate
                            }
                            return nil
                        }
                        
                        DispatchQueue.main.async {
                            exchangeRates = rates
                            print("成功保存匯率數據：\(exchangeRates)")
                        }
                    }
                } catch {
                    print("解析失敗: \(error)")
                }
            } else if let error = error {
                print("請求失敗：\(error)")
            }
        }.resume()
    }
    func convertCurrency() {
        guard let amountValue = Double(newMoney),
              let sourceRate = exchangeRates[selectedCurrency],
              let targetRate = exchangeRates[targetCurrency] else {
            convertedAmount = nil
            return
        }
        convertedAmount = Int(amountValue / sourceRate * targetRate)
    }
}
