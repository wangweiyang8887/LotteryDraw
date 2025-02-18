import SwiftUI

struct LotteryResultView: View {
    @State private var selectedType: LotteryType = .doubleColorBall
    @State private var results: [LotteryResult] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 玩法选择器
                Picker("彩票类型", selection: $selectedType) {
                    ForEach(LotteryType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: selectedType) { _, _ in
                    loadResults()
                }
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding()
                } else if let error = errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text(error)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    // 开奖结果列表
                    List(results) { result in
                        ResultRow(result: result, type: selectedType)
                    }
                    .refreshable {
                        await refreshResults()
                    }
                }
            }
            .navigationTitle("开奖结果")
        }
        .onAppear {
            loadResults()
        }
    }
    
    private func loadResults() {
        isLoading = true
        errorMessage = nil
        
        // 模拟网络请求延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // TODO: 替换为实际的网络请求
            results = mockResults(for: selectedType)
            isLoading = false
        }
    }
    
    private func refreshResults() async {
        isLoading = true
        errorMessage = nil
        
        // 模拟网络请求
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        results = mockResults(for: selectedType)
        isLoading = false
    }
    
    // 模拟数据
    private func mockResults(for type: LotteryType) -> [LotteryResult] {
        switch type {
        case .doubleColorBall:
            return [
                LotteryResult(id: "2024001", date: "2024-01-02", numbers: [1, 7, 9, 15, 23, 28, 12], prize: "1000万"),
                LotteryResult(id: "2024002", date: "2024-01-05", numbers: [3, 8, 11, 19, 25, 32, 16], prize: "500万"),
                LotteryResult(id: "2024003", date: "2024-01-07", numbers: [2, 6, 13, 21, 27, 33, 8], prize: "800万")
            ]
        case .bigLotto:
            return [
                LotteryResult(id: "24001", date: "2024-01-01", numbers: [5, 11, 17, 23, 31, 2, 9], prize: "1500万"),
                LotteryResult(id: "24002", date: "2024-01-04", numbers: [7, 13, 19, 25, 33, 4, 11], prize: "700万"),
                LotteryResult(id: "24003", date: "2024-01-07", numbers: [2, 8, 14, 22, 35, 3, 8], prize: "900万")
            ]
        case .lottery3D:
            return [
                LotteryResult(id: "24001", date: "2024-01-01", numbers: [3, 5, 7], prize: "1040"),
                LotteryResult(id: "24002", date: "2024-01-02", numbers: [1, 4, 6], prize: "1040"),
                LotteryResult(id: "24003", date: "2024-01-03", numbers: [2, 8, 9], prize: "1040")
            ]
        case .arrangement3:
            return [
                LotteryResult(id: "24001", date: "2024-01-01", numbers: [2, 4, 6], prize: "1040"),
                LotteryResult(id: "24002", date: "2024-01-02", numbers: [1, 3, 5], prize: "1040"),
                LotteryResult(id: "24003", date: "2024-01-03", numbers: [7, 8, 9], prize: "1040")
            ]
        case .arrangement5:
            return [
                LotteryResult(id: "24001", date: "2024-01-01", numbers: [2, 4, 6, 8, 0], prize: "10万"),
                LotteryResult(id: "24002", date: "2024-01-02", numbers: [1, 3, 5, 7, 9], prize: "10万"),
                LotteryResult(id: "24003", date: "2024-01-03", numbers: [7, 8, 9, 1, 2], prize: "10万")
            ]
        }
    }
}

// 单行开奖结果视图
struct ResultRow: View {
    let result: LotteryResult
    let type: LotteryType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 期号和日期
            HStack {
                Text("第\(result.id)期")
                    .font(.headline)
                Spacer()
                Text(result.date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // 开奖号码
            HStack(spacing: 8) {
                ForEach(Array(result.numbers.enumerated()), id: \.offset) { index, number in
                    NumberBall(number: number, type: type, index: index)
                }
            }
            
            // 奖池信息
            HStack {
                Text("奖池：")
                    .foregroundColor(.secondary)
                Text(result.prize)
                    .foregroundColor(.red)
            }
            .font(.subheadline)
        }
        .padding(.vertical, 8)
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
        Text("\(number)")
            .font(.system(.body, design: .rounded).bold())
            .foregroundColor(.white)
            .frame(width: 32, height: 32)
            .background(
                Circle()
                    .fill(ballColor)
            )
    }
}

// 开奖结果模型
struct LotteryResult: Identifiable {
    let id: String
    let date: String
    let numbers: [Int]
    let prize: String
}

#Preview {
    LotteryResultView()
} 