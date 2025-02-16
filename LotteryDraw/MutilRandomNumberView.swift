//
//  MutilRandomNumberView.swift
//  LotteryDraw
//
//  Created by evan on 2025/2/16.
//

import SwiftUI

// MARK: - 核心视图
struct AnimatedNumberView: View {
    @State private var targetNumber: Int = 0
    @State private var currentNumber: CGFloat = 0
    private let range: ClosedRange<Int> = 0...100
    
    var body: some View {
        VStack(spacing: 40) {
            // 滚动数字样式
            RollingNumberDisplay(number: targetNumber)
                .frame(height: 80)
            
            // 插值动画样式
            Text("\(Int(targetNumber))")
                .animatableNumber(font: .system(size: 64, weight: .heavy),
                                 color: .blue)
            
            Button("生成随机数") {
                generateNewNumber()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private func generateNewNumber() {
        let newNumber = Int.random(in: range)
        targetNumber = newNumber
        
        // 插值动画
        withAnimation(.easeOut(duration: 1.5)) {
            currentNumber = CGFloat(newNumber)
        }
    }
}

// MARK: - 滚动数字组件
struct RollingNumberDisplay: View {
    let number: Int
    private var digits: [Int] {
        String(format: "%04d", number).compactMap { Int(String($0)) }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(digits.indices, id: \.self) { index in
                SingleDigitView(digit: digits[index])
                    .transition(.roll)
            }
        }
    }
}

// MARK: - 单个数字滚动组件
struct SingleDigitView: View {
    let digit: Int
    @State private var containerHeight: CGFloat = 0
    
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                ForEach(0...9, id: \.self) { number in
                    Text("\(number)")
                        .font(.system(size: 60, weight: .bold))
                        .frame(height: proxy.size.height)
                }
            }
            .frame(height: proxy.size.height, alignment: .top)
            .offset(y: -CGFloat(digit) * proxy.size.height)
            .background(GeometryReader {
                Color.clear.preference(key: HeightKey.self, value: $0.size.height)
            })
        }
        .onPreferenceChange(HeightKey.self) { containerHeight = $0 }
        .clipped()
        .frame(width: 40, height: containerHeight / 10)
    }
}

// MARK: - 自定义动画修饰器
struct AnimatableNumber: AnimatableModifier {
    var number: CGFloat
    let font: Font
    let color: Color
    
    var animatableData: CGFloat {
        get { number }
        set { number = newValue }
    }
    
    func body(content: Content) -> some View {
        Text("\(Int(number))")
            .font(font)
            .foregroundColor(color)
            .contentTransition(.numericText())
    }
}

// MARK: - 过渡效果扩展
extension AnyTransition {
    static var roll: AnyTransition {
        .modifier(
            active: RollEffect(progress: 0),
            identity: RollEffect(progress: 1)
        )
    }
}

struct RollEffect: GeometryEffect {
    var progress: CGFloat
    
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let rotation = Angle(degrees: 90 * (1 - progress))
        let translation = CGSize(width: 0, height: -size.height * (1 - progress))
        
        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: translation.width, y: translation.height)
        transform = transform.rotated(by: CGFloat(rotation.radians))
        
        return ProjectionTransform(transform)
    }
}

// MARK: - 辅助工具
extension View {
    func animatableNumber(font: Font, color: Color) -> some View {
        modifier(AnimatableNumber(number: 0, font: font, color: color))
    }
}

struct HeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

