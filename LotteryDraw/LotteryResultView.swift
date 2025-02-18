import SwiftUI

struct LotteryResultView: View {
    @State private var selectedType: LotteryType = .doubleColorBall
    @State private var results: [LotteryResult] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // 本地存储相关的键
    private let storageKey = "lottery_results_cache"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 玩法选择器 - 固定在顶部
                Picker("彩票类型", selection: $selectedType) {
                    ForEach(LotteryType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(
                    Rectangle()
                        .fill(Color(.systemBackground))
                        .shadow(color: .gray.opacity(0.1), radius: 3, y: 2)
                )
                .onChange(of: selectedType) { _, _ in
                    loadResults()
                }
                
                // 内容区域 - 可滚动
                ScrollView {
                    if isLoading {
                        VStack {
                            Spacer(minLength: 100)
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("加载中...")
                                .foregroundColor(.secondary)
                                .padding(.top)
                            Spacer()
                        }
                        .frame(minHeight: 300)
                    } else if let error = errorMessage {
                        VStack(spacing: 16) {
                            Spacer(minLength: 100)
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            
                            Text(error)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                        .frame(minHeight: 300)
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(results, id: \.self.result.lottery_id) { result in
                                ResultRow(result: result.result, type: selectedType)
                                    .padding(.horizontal, 16)
                            }
                        }
                        .padding(.vertical)
                    }
                }
                .refreshable {
                    await refreshResults()
                }
                .frame(width: UIScreen.main.bounds.width)
                .background(Color.clear)
            }
            .navigationTitle("开奖结果")
        }
        .onAppear {
            loadResults()
        }
    }
    
    // 从本地存储加载数据
    private func loadFromStorage(for type: LotteryType) -> [LotteryResult]? {
        if let data = UserDefaults.standard.data(forKey: "\(storageKey)_\(type.rawValue)"),
           let decodedResults = try? JSONDecoder().decode([LotteryResult].self, from: data) {
            return decodedResults
        }
        return nil
    }
    
    // 保存数据到本地存储
    private func saveToStorage(results: [LotteryResult], for type: LotteryType) {
        if let encoded = try? JSONEncoder().encode(results) {
            UserDefaults.standard.set(encoded, forKey: "\(storageKey)_\(type.rawValue)")
        }
    }
    
    private func loadResults() {
        isLoading = true
        errorMessage = nil
        
        // 先尝试从本地加载
        if let storedResults = loadFromStorage(for: selectedType) {
            results = storedResults
            isLoading = false
            return
        }
        
        // 如果本地没有数据，则从网络加载
        Server.shared.getLottery(with: selectedType.lottery_id) { result in
            if case .success(let value) = result {
                let newResult = LotteryResult(result: value)
                
                // 检查是否存在相同期号
                if !results.contains(where: { $0.result.lottery_no == newResult.result.lottery_no }) {
                    // 将新数据添加到数组开头
                    results.insert(newResult, at: 0)
                    // 保存到本地存储
                    saveToStorage(results: results, for: selectedType)
                }
                errorMessage = nil
            } else {
                errorMessage = "暂无数据"
            }
            isLoading = false
        }
    }
    
    private func refreshResults() async {
        // 刷新时清除本地存储
//        UserDefaults.standard.removeObject(forKey: "\(storageKey)_\(selectedType.rawValue)")
//        Task {
//            loadResults()
//        }
    }
}

// 单行开奖结果视图
struct ResultRow: View {
    let result: LotteryModel
    let type: LotteryType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("第\(result.lottery_no)期")
                    .font(.headline)
                Spacer()
                Text(result.lottery_date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 8) {
                ForEach(Array(result.lottery_res.components(separatedBy: ",").enumerated()), id: \.offset) { index, number in
                    NumberBall(number: Int(number) ?? 0, type: type, index: index)
                }
            }
            
            HStack {
                Text("奖池：")
                    .foregroundColor(.secondary)
                Text(result.lottery_pool_amount)
                    .foregroundColor(.red)
                    .bold()
            }
            .font(.subheadline)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

// 号码球视图
struct NumberBall: View {
    let number: Int
    let type: LotteryType
    let index: Int
    
    var ballColor: Color {
        switch type {
        case .doubleColorBall:
            return index == 6 ? .blue : .red
        case .bigLotto:
            return index >= 5 ? .blue : .red
        case .lottery3D, .arrangement3:
            return .blue
        case .arrangement5:
            return .green
        }
    }
    
    var body: some View {
        Text(String(format: "%02d", number))
            .font(.system(.body, design: .rounded, weight: .bold))
            .foregroundColor(.white)
            .frame(width: 32, height: 32)
            .background(
                Circle()
                    .fill(ballColor)
            )
    }
}

// 为了确保正确比较，让 LotteryResult 符合 Equatable
extension LotteryResult: Equatable {
    static func == (lhs: LotteryResult, rhs: LotteryResult) -> Bool {
        return lhs.result.lottery_no == rhs.result.lottery_no
    }
}

// 确保 LotteryResult 可以被编码和解码
extension LotteryResult {
    enum CodingKeys: String, CodingKey {
        case result
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        result = try container.decode(LotteryModel.self, forKey: .result)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(result, forKey: .result)
    }
}


#Preview {
    LotteryResultView()
} 
