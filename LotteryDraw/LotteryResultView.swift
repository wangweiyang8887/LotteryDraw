import SwiftUI

struct LotteryResultView: View {
    @State private var selectedType: LotteryType = .doubleColorBall
    @State private var results: [LotteryResult] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
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
                .padding()
                .background(Color(UIColor.systemBackground))
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
                        VStack {
                            Spacer(minLength: 100)
                            Image(systemName: "exclamationmark.triangle")
                                .font(.largeTitle)
                                .foregroundColor(.orange)
                            Text(error)
                                .foregroundColor(.secondary)
                                .padding(.top)
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
        
        Server.shared.getLottery(with: selectedType.lottery_id) { result in
            if case .success(let value) = result {
                results.append(LotteryResult(result: value))
                errorMessage = nil
            } else {
                errorMessage = "暂无数据"
            }
            isLoading = false
        }
    }
    
    private func refreshResults() async {
        Task {
            loadResults()
        }
    }
}

// 单行开奖结果视图
struct ResultRow: View {
    let result: LotteryModel
    let type: LotteryType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 期号和日期
            HStack {
                Text("第\(result.lottery_no)期")
                    .font(.headline)
                Spacer()
                Text(result.lottery_date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // 开奖号码
            HStack(spacing: 6) {
                ForEach(Array(result.lottery_res.components(separatedBy: ",").enumerated()), id: \.offset) { index, number in
                    NumberBall(number: Int(number) ?? 0, type: type, index: index)
                }
            }
            .padding(.vertical, 4)
            
            // 奖池信息
            HStack {
                Text("奖池：")
                    .foregroundColor(.secondary)
                Text(result.lottery_pool_amount)
                    .foregroundColor(.red)
                    .bold()
            }
            .font(.subheadline)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
        )
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
            .font(.system(.body, design: .rounded, weight: .bold))
            .foregroundColor(.white)
            .frame(width: 36, height: 36)
            .background(
                Circle()
                    .fill(ballColor.gradient)
                    .shadow(color: ballColor.opacity(0.3), radius: 3, x: 0, y: 2)
            )
            .overlay(
                Circle()
                    .stroke(.white.opacity(0.3), lineWidth: 1)
            )
            .overlay(
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.white.opacity(0.5), .clear],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 20
                        )
                    )
                    .padding(4)
            )
    }
}

#Preview {
    LotteryResultView()
} 
