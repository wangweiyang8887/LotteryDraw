import SwiftUI

struct LuckyNumberView: View {
    @State private var luckyNumber: Int = 0
    @State private var isAnimating = false
    @State private var timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    @State private var maxRange: Double = 99 // 默认最大值
    
    // 计算当前范围
    private var currentRange: ClosedRange<Int> {
        0...Int(maxRange)
    }
    
    // 数字格式化
    private var numberFormat: String {
        let maxValue = Int(maxRange)
        if maxValue <= 9 {
            return "%d"
        } else if maxValue <= 99 {
            return "%d"
        } else {
            return "%d"
        }
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Text("今日幸运数字")
                .font(.title2.bold())
            // 范围选择器
            VStack(spacing: 10) {
                HStack {
                    Text("范围: 0 - \(Int(maxRange))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Slider(
                    value: $maxRange,
                    in: 9...999,
                    step: 1
                ) { editing in
                    if !editing {
                        // 只重置数字，不调整范围值
                        resetNumber()
                    }
                }
                .tint(.purple)
            }
            .padding(.horizontal)
            
            Text("选择一个数字，带来好运")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // 数字显示
            NumberRollView(
                finalNumber: luckyNumber,
                isAnimating: isAnimating,
                timer: timer,
                range: currentRange,
                color: .purple,
                format: numberFormat,
                size: 40
            )
            .frame(width: 120, height: 120)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.gray.opacity(0.1))
            )
            
            // 生成按钮
            Button(action: generateLuckyNumber) {
                Text("生成幸运数字")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .frame(width: 200)
                    .padding()
                    .background(
                        Capsule()
                            .fill(isAnimating ? .gray : .blue)
                    )
            }
            .disabled(isAnimating)
        }
        .padding()
    }
    
    private func resetNumber() {
        // 停止任何正在进行的动画
        isAnimating = false
        timer.upstream.connect().cancel()
        // 重置数字
        luckyNumber = 0
    }
    
    private func generateLuckyNumber() {
        timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
        isAnimating = true
        
        // 先重置显示
        luckyNumber = 0
        
        // 延迟后停止动画并显示最终数字
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                luckyNumber = Int.random(in: currentRange)
                isAnimating = false
            }
            timer.upstream.connect().cancel()
        }
    }
} 
