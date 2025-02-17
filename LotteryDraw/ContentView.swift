              //
//  ContentView.swift
//  LotteryDraw
//
//  Created by evan on 2025/2/16.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationView {
                MultiRandomNumberView()
                    .navigationTitle("彩票摇号")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("彩票摇号", systemImage: "ticket.fill")
            }
            
            NavigationView {
                LuckyNumberView()
                    .navigationTitle("幸运数字")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("幸运数字", systemImage: "star.fill")
            }
        }
    }
}

struct IncreaseDecrease: View {
    @State private var rating: Int = 0
    private let numberRange: ClosedRange<Int> = 0...99
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 20) {
            Button("Decrease", systemImage: "minus.circle") {
                withAnimation {
                    rating = Int.random(in: numberRange)
                }
            }
            .disabled(rating == 0)
            Spacer()
            Text(rating, format: .number)
                .font(.title)
                .bold()
                .disabled(rating == 100)
                .contentTransition(.numericText(value: Double(rating)))
                .animation(.linear(duration: 0.25), value: Double(rating))
            Spacer()
            Button("Increase", systemImage: "plus.circle") {
                withAnimation {
                    rating = Int.random(in: numberRange)
                }
            }
            .disabled(rating == 100)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
        .shadow(radius: 5)
    }
}

struct MultiRandomNumbersView: View {
    // 控制数字数量和范围
    @State private var numbers: [Int] = Array(repeating: 0, count: 5)
    @State private var lastUpdate = Date.now
    private let numberRange: ClosedRange<Int> = 0...99
    private let numberOfDice: Int = 5
    
    // 布局参数
    @State private var isVerticalLayout = false
    @State private var isRolling = false
    private let rollDuration = 2.0
    
    var body: some View {
        VStack(spacing: 30) {
            // 布局切换控制
            Picker("布局", selection: $isVerticalLayout) {
                Text("横向").tag(false)
                Text("纵向").tag(true)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            // 数字显示区
            layoutView
                .id(isVerticalLayout) // 强制布局刷新
                .transition(.scale.combined(with: .opacity))
            
            // 控制面板
            controlPanel
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
        .onAppear(perform: generateNumbers)
    }
    
    // 动态布局切换
    @ViewBuilder
    private var layoutView: some View {
        if isVerticalLayout {
            VStack(spacing: 20) {
                numberElements
            }
        } else {
            HStack(spacing: 20) {
                numberElements
            }
        }
    }
    
    // 数字元素组
    private var numberElements: some View {
        ForEach(numbers.indices, id: \.self) { index in
            Text("\(numbers[index])")
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundColor(colorForNumber(numbers[index]))
                .frame(width: 80, height: 80)
                .background(.background)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .primary.opacity(0.2), radius: 3, x: 0, y: 2)
                .contentTransition(.numericText(value: Double(numbers[index])))
                .animation(
                    .spring(response: 0.5, dampingFraction: 0.8)
                    .delay(Double(index) * 0.1),
                    value: numbers[index]
                )
        }
    }
    
    // 控制面板
    private var controlPanel: some View {
        VStack(spacing: 20) {
            Button(action: generateNumbers) {
                Label("全部随机", systemImage: "dice")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .shadow(radius: 2)
            
            Button("单个随机") {
                randomizeSingleNumber()
            }
            .buttonStyle(.bordered)
            
            Text("最后更新: \(lastUpdate.formatted(date: .omitted, time: .standard))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
    
    // 颜色逻辑
    private func colorForNumber(_ number: Int) -> Color {
        switch number {
        case 0...33: return .red
        case 34...66: return .orange
        default: return .green
        }
    }
    
    // 生成全部随机数
    private func generateNumbers() {
        guard !isRolling else { return }
        isRolling = true
        
        // 创建多个中间状态的动画
        let steps = 20
        let stepDuration = rollDuration / Double(steps)
        
        for step in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(step)) {
                withAnimation {
                    numbers = numbers.map { _ in
                        Int.random(in: numberRange)
                    }
                }
                
                if step == steps {
                    lastUpdate = .now
                    isRolling = false
                }
            }
        }
    }
    
    // 随机替换单个数字
    private func randomizeSingleNumber() {
        guard !isRolling else { return }
        guard !numbers.isEmpty else { return }
        
        let randomIndex = Int.random(in: numbers.indices)
        isRolling = true
        
        // 创建多个中间状态的动画
        let steps = 10
        let stepDuration = rollDuration / 2 / Double(steps)
        
        for step in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(step)) {
                withAnimation(.easeInOut) {
                    numbers[randomIndex] = Int.random(in: numberRange)
                }
                
                if step == steps {
                    lastUpdate = .now
                    isRolling = false
                }
            }
        }
    }
}

#Preview {
    MultiRandomNumbersView()
}

#Preview {
    ContentView()
}
