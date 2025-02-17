//
//  MutilRandomNumberView.swift
//  LotteryDraw
//
//  Created by evan on 2025/2/16.
//

import SwiftUI
import Combine

// 彩票类型枚举
enum LotteryType: String, CaseIterable {
    case doubleColorBall = "双色球"    // 6红1蓝：红球1-33，蓝球1-16
    case bigLotto = "大乐透"          // 5前2后：前区1-35，后区1-12
    case lottery3D = "福彩3D"         // 3位数：000-999
    case arrangement3 = "排列3"       // 3位数：000-999
    case arrangement5 = "排列5"       // 5位数：00000-99999
    
    var description: String {
        switch self {
        case .doubleColorBall:
            return "红球区间1-33，蓝球区间1-16"
        case .bigLotto:
            return "前区区间1-35，后区区间1-12"
        case .lottery3D:
            return "3位数区间000-999"
        case .arrangement3:
            return "3位数区间000-999"
        case .arrangement5:
            return "5位数区间00000-99999"
        }
    }
    
    var numberCount: Int {
        switch self {
        case .doubleColorBall, .bigLotto:
            return 7
        case .lottery3D, .arrangement3:
            return 3
        case .arrangement5:
            return 5
        }
    }
    
    var numberColor: Color {
        switch self {
        case .lottery3D:
            return .purple
        case .arrangement3:
            return .orange
        case .arrangement5:
            return .green
        default:
            return .red
        }
    }
}

// MARK: - 多数字随机生成视图
struct MultiRandomNumberView: View {
    @StateObject private var recordManager = LotteryRecordManager()
    @State private var selectedType: LotteryType = .doubleColorBall
    @State private var numbers: [Int] = []  // 初始化为空数组
    @State private var isAnimating = false
    @State private var timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    @State private var showHistory = false
    
    // 添加初始化
    init() {
        _numbers = State(initialValue: Array(repeating: 0, count: LotteryType.doubleColorBall.numberCount))
    }
    
    var body: some View {
        VStack(spacing: 30) {
            // 彩票类型选择
            Picker("彩票类型", selection: $selectedType.animation()) {
                ForEach(LotteryType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            // 规则说明
            Text(selectedType.description)
                .font(.footnote)
                .foregroundColor(.gray)
            
            // 数字显示区域
            HStack(spacing: 12) {
                Group {
                    switch selectedType {
                    case .doubleColorBall:
                        // 双色球：6个红球
                        ForEach(0..<6, id: \.self) { index in
                            NumberRollView(
                                finalNumber: numbers.indices.contains(index) ? numbers[index] : 0,
                                isAnimating: isAnimating,
                                timer: timer,
                                range: 1...33,
                                color: .red,
                                format: "%02d"
                            )
                        }
                        // 1个蓝球
                        if numbers.indices.contains(6) {
                            NumberRollView(
                                finalNumber: numbers[6],
                                isAnimating: isAnimating,
                                timer: timer,
                                range: 1...16,
                                color: .blue,
                                format: "%02d"
                            )
                        }
                        
                    case .bigLotto:
                        // 大乐透：5个前区号码
                        ForEach(0..<5, id: \.self) { index in
                            NumberRollView(
                                finalNumber: numbers.indices.contains(index) ? numbers[index] : 0,
                                isAnimating: isAnimating,
                                timer: timer,
                                range: 1...35,
                                color: .red,
                                format: "%02d"
                            )
                        }
                        // 2个后区号码
                        ForEach(5..<7, id: \.self) { index in
                            if numbers.indices.contains(index) {
                                NumberRollView(
                                    finalNumber: numbers[index],
                                    isAnimating: isAnimating,
                                    timer: timer,
                                    range: 1...12,
                                    color: .blue,
                                    format: "%02d"
                                )
                            }
                        }
                        
                    case .lottery3D, .arrangement3:
                        // 福彩3D和排列3：3位数
                        ForEach(0..<3, id: \.self) { index in
                            NumberRollView(
                                finalNumber: numbers.indices.contains(index) ? numbers[index] : 0,
                                isAnimating: isAnimating,
                                timer: timer,
                                range: 0...9,
                                color: selectedType.numberColor,
                                format: "%d"
                            )
                        }
                        
                    case .arrangement5:
                        // 排列5：5位数
                        ForEach(0..<5, id: \.self) { index in
                            NumberRollView(
                                finalNumber: numbers.indices.contains(index) ? numbers[index] : 0,
                                isAnimating: isAnimating,
                                timer: timer,
                                range: 0...9,
                                color: .green,
                                format: "%d"
                            )
                        }
                    }
                }
                .frame(width: selectedType == .doubleColorBall || selectedType == .bigLotto ? 45 : 35, height: 45)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.gray.opacity(0.1))
                )
            }
            .padding(.horizontal, 15)
            
            // 生成按钮
            Button(action: generateNumbers) {
                Text("开始摇号")
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
            
            // 添加历史记录按钮
            Button(action: { showHistory.toggle() }) {
                Label("历史记录", systemImage: "clock.arrow.circlepath")
                    .font(.headline)
            }
            .sheet(isPresented: $showHistory) {
                HistoryView(recordManager: recordManager, selectedType: selectedType)
            }
        }
        .padding(.vertical)
        .onChange(of: selectedType) { _,_ in
            withAnimation {
                resetNumbers()
            }
        }
    }
    
    private func resetNumbers() {
        withAnimation {
            isAnimating = false
            timer.upstream.connect().cancel()
            numbers = Array(repeating: 0, count: selectedType.numberCount)
        }
    }
    
    private func generateNumbers() {
        // 重置计时器
        timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
        isAnimating = true
        
        // 生成新的随机数
        var newNumbers: [Int] = []
        
        switch selectedType {
        case .doubleColorBall:
            // 生成双色球号码：6个不重复的红球(1-33) + 1个蓝球(1-16)
            var redBalls = Set<Int>()
            while redBalls.count < 6 {
                let newNumber = Int.random(in: 1...33)
                if !redBalls.contains(newNumber) {
                    redBalls.insert(newNumber)
                }
            }
            newNumbers = Array(redBalls).sorted()
            newNumbers.append(Int.random(in: 1...16))
            
        case .bigLotto:
            // 生成大乐透号码：5个不重复的前区号码(1-35) + 2个不重复的后区号码(1-12)
            var frontNumbers = Set<Int>()
            var backNumbers = Set<Int>()
            
            // 生成前区号码（1-35中选5个不重复的数）
            while frontNumbers.count < 5 {
                let newNumber = Int.random(in: 1...35)
                if !frontNumbers.contains(newNumber) {
                    frontNumbers.insert(newNumber)
                }
            }
            
            // 生成后区号码（1-12中选2个不重复的数）
            while backNumbers.count < 2 {
                let newNumber = Int.random(in: 1...12)
                if !backNumbers.contains(newNumber) {
                    backNumbers.insert(newNumber)
                }
            }
            
            // 将前区号码排序后添加到结果中
            newNumbers = Array(frontNumbers).sorted()
            // 将后区号码排序后添加到结果中
            newNumbers.append(contentsOf: Array(backNumbers).sorted())
            
        case .lottery3D, .arrangement3:
            // 生成3D号码：3个0-9的数字
            for _ in 0..<3 {
                newNumbers.append(Int.random(in: 0...9))
            }
            
        case .arrangement5:
            // 生成排列5号码：5个0-9的数字
            for _ in 0..<5 {
                newNumbers.append(Int.random(in: 0...9))
            }
        }
        
        // 先更新 numbers 数组
        numbers = Array(repeating: 0, count: selectedType.numberCount)
        
        // 延迟后停止动画并显示最终数字
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                numbers = newNumbers
                isAnimating = false
            }
            timer.upstream.connect().cancel()
            
            // 保存记录
            let record = LotteryRecord(type: selectedType, numbers: newNumbers)
            recordManager.addRecord(record)
        }
    }
}

struct NumberRollView: View {
    let finalNumber: Int
    let isAnimating: Bool
    let timer: Publishers.Autoconnect<Timer.TimerPublisher>
    let range: ClosedRange<Int>
    let color: Color
    let format: String
    @State private var currentNumber: Int = 0
    
    var body: some View {
        Text(String(format: format, currentNumber))
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .monospacedDigit()
            .foregroundColor(color)
            .contentTransition(.numericText())
            .onReceive(timer) { _ in
                withAnimation {
                    if isAnimating {
                        currentNumber = Int.random(in: range)
                    } else {
                        // 确保停止时显示最终数字
                        currentNumber = finalNumber
                    }
                }
            }
            // 添加监听 finalNumber 的变化
            .onChange(of: finalNumber) { _, newValue in
                if !isAnimating {
                    currentNumber = newValue
                }
            }
            // 添加监听 isAnimating 的变化
            .onChange(of: isAnimating) { _, newValue in
                if !newValue {
                    currentNumber = finalNumber
                }
            }
        }
}

