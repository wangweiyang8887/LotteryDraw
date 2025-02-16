//
//  ContentView.swift
//  LotteryDraw
//
//  Created by evan on 2025/2/16.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            TabView {
                LotteryStyle1().tabItem { Label("双色球", systemImage: "1.circle") }
                LotteryStyle2().tabItem { Label("大乐透", systemImage: "2.circle") }
                LotteryStyle3().tabItem { Label("排列五", systemImage: "3.circle") }
                LotteryStyle4().tabItem { Label("历史", systemImage: "clock") }
                LotteryStyle5().tabItem { Label("奖池", systemImage: "dollarsign.circle") }
            }
            .accentColor(.orange)
        }
        .padding()
    }
}

struct LotteryResultsView: View {
    @State private var doubleBallNumbers: [Int] = Array(repeating: 0, count: 6)
    @State private var doubleBallSpecial: Int = 0
    @State private var powerBallNumbers: [Int] = Array(repeating: 0, count: 5)
    @State private var powerBallSpecial: Int = 0
    @State private var isRevealing = false
    
    let actualDoubleBallNumbers = [3, 12, 25, 36, 42, 49]
    let actualDoubleBallSpecial = 15
    let actualPowerBallNumbers = [7, 18, 24, 30, 41]
    let actualPowerBallSpecial = 9
    
    var body: some View {
        VStack(spacing: 30) {
            Text("🎉 彩票中奖结果 🎉")
                .font(.largeTitle)
                .bold()
            
            VStack(spacing: 20) {
                Text("双色球")
                    .font(.title2)
                    .bold()
                
                HStack {
                    ForEach(0..<doubleBallNumbers.count, id: \.self) { index in
                        ballView(number: doubleBallNumbers[index], color: .red)
                    }
                    ballView(number: doubleBallSpecial, color: .blue)
                }
            }
            
            VStack(spacing: 20) {
                Text("大乐透")
                    .font(.title2)
                    .bold()
                
                HStack {
                    ForEach(0..<powerBallNumbers.count, id: \.self) { index in
                        ballView(number: powerBallNumbers[index], color: .orange)
                    }
                    ballView(number: powerBallSpecial, color: .yellow)
                }
            }
            
            Button(action: revealResults) {
                Text("揭晓中奖号码")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }
    
    private func ballView(number: Int, color: Color) -> some View {
        Text("\(number)")
            .font(.title)
            .bold()
            .frame(width: 50, height: 50)
            .background(Circle().fill(color.opacity(0.8)))
            .foregroundColor(.white)
            .transition(.scale)
            .animation(.easeInOut(duration: 0.5), value: number)
    }
    
    private func revealResults() {
        isRevealing = false
        doubleBallNumbers = Array(repeating: 0, count: 6)
        doubleBallSpecial = 0
        powerBallNumbers = Array(repeating: 0, count: 5)
        powerBallSpecial = 0
        
        for i in 0..<doubleBallNumbers.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.5) {
                withAnimation {
                    doubleBallNumbers[i] = actualDoubleBallNumbers[i]
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                doubleBallSpecial = actualDoubleBallSpecial
            }
        }
        
        for i in 0..<powerBallNumbers.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.5) {
                withAnimation {
                    powerBallNumbers[i] = actualPowerBallNumbers[i]
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                powerBallSpecial = actualPowerBallSpecial
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
//                .animation(
//                    .spring(response: 0.3, dampingFraction: 0.7),
//                    value: numbers
//                )
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
        withAnimation(.easeInOut(duration: 0.5)) {
            numbers = numbers.map { _ in
                Int.random(in: numberRange)
            }
            lastUpdate = .now
        }
    }
    
    // 随机替换单个数字
    private func randomizeSingleNumber() {
        guard !numbers.isEmpty else { return }
        
        let randomIndex = Int.random(in: numbers.indices)
        withAnimation(.bouncy) {
            numbers[randomIndex] = Int.random(in: numberRange)
            lastUpdate = .now
        }
    }
}

#Preview {
    MultiRandomNumbersView()
}

#Preview {
    ContentView()
}
