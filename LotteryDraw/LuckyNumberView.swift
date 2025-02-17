import SwiftUI

struct LuckyNumberView: View {
    @State private var luckyNumber: Int = 0
    @State private var isAnimating = false
    @State private var timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 30) {
            Text("今日幸运数字")
                .font(.title2.bold())
            
            Text("选择一个数字，带来好运")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // 数字显示
            NumberRollView(
                finalNumber: luckyNumber,
                isAnimating: isAnimating,
                timer: timer,
                range: 0...99,
                color: .purple,
                format: "%ld",
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
    
    private func generateLuckyNumber() {
        timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
        isAnimating = true
        
        // 先重置显示
        luckyNumber = 0
        
        // 延迟后停止动画并显示最终数字
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                luckyNumber = Int.random(in: 0...99)
                isAnimating = false
            }
            timer.upstream.connect().cancel()
        }
    }
} 
