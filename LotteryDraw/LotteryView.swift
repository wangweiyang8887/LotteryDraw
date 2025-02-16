//
//  LotteryView.swift
//  LotteryDraw
//
//  Created by evan on 2025/2/16.
//

import SwiftUI

struct LotteryStyle1: View {
    let period = "第 2023088 期"
    let date = "2023年8月1日"
    let redBalls = ["06", "12", "18", "23", "29", "33"]
    let blueBall = "09"
    
    var body: some View {
        VStack(spacing: 15) {
            HeaderView(title: "双色球开奖结果", icon: "tag.fill")
            
            VStack(spacing: 12) {
                InfoRow(title: "期号", value: period)
                InfoRow(title: "开奖日期", value: date)
                
                HStack {
                    ForEach(redBalls, id: \.self) { ball in
                        BallView(number: ball, color: .red, type: "红球")
                    }
                    BallView(number: blueBall, color: .blue, type: "蓝球")
                }
                
//                PrizePoolView(amount: "7.89 亿")
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThickMaterial))
        }
        .padding()
    }
}

struct BallView: View {
    let number: String
    let color: Color
    let type: String
    
    var body: some View {
        VStack {
            Text(number)
                .font(.system(size: 20, weight: .bold))
                .frame(width: 40, height: 40)
                .background(Circle().fill(color.gradient))
                .foregroundColor(.white)
            
            Text(type)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct LotteryStyle2: View {
    @State private var showDetails = false
    let numbers = (front: ["03", "15", "22", "28", "34"], back: ["05", "09"])
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                ForEach(numbers.front, id: \.self) { num in
                    AnimatedBall(number: num, color: .purple)
                        .rotationEffect(.degrees(showDetails ? -360 : 0))
                }
                
                ForEach(numbers.back, id: \.self) { num in
                    AnimatedBall(number: num, color: .teal)
                        .offset(y: showDetails ? 0 : -50)
                }
            }
            .onTapGesture { withAnimation(.spring()) { showDetails.toggle() } }
            
            if showDetails {
//                PrizeDetailsView()
//                    .transition(.move(edge: .bottom))
            }
        }
    }
}

struct LotteryStyle3: View {
    let numbers = ["7", "3", "9", "1", "5"]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(numbers, id: \.self) { num in
                Text(num)
                    .font(.system(size: 40, weight: .black))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        Color(UIColor.systemBackground)
                            .overlay(Rectangle().fill(.gray.opacity(0.2)).frame(width: 1),
                        alignment: .trailing))
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.gray.opacity(0.3), lineWidth: 1)
        )
        .padding()
    }
}

struct LotteryStyle4: View {
    let history = [
        ("2023087", ["12","18","23","29","33","06"], "09"),
        ("2023086", ["04","11","19","25","30","15"], "12")
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("历史开奖记录")
                    .font(.title2.bold())
                    .padding(.bottom)
                
                ForEach(history, id: \.0) { item in
                    TimelineRow(period: item.0, red: item.1, blue: item.2)
                        .padding(.vertical, 8)
                    Divider()
                }
            }
            .padding()
        }
    }
}

struct LotteryStyle5: View {
    @State private var rotation: CGFloat = 0
    let jackpot: String = "¥835,621,459"
    
    var body: some View {
        VStack {
            Text("当前奖池")
                .font(.title3)
                .padding(.bottom, 5)
            
            Text(jackpot)
                .font(.system(size: 32, weight: .heavy, design: .rounded))
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            AngularGradient(
                                colors: [.red, .yellow, .green, .blue, .purple, .red],
                                center: .center
                            )
                        )
                        .rotation3DEffect(.degrees(rotation), axis: (x: 1, y: 1, z: 0))
                )
                .onAppear {
                    withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                }
            
            Text("元")
                .font(.caption)
                .offset(y: -10)
        }
    }
}

struct TimelineRow: View {
    let period: String
    let red: [String]
    let blue: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(period)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    ForEach(red, id: \.self) { num in
                        Text(num)
                            .boldNumberStyle(color: .red)
                    }
                    Text(blue)
                        .boldNumberStyle(color: .blue)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
    }
}

struct AnimatedBall: View {
    let number: String
    let color: Color
    
    var body: some View {
        Text(number)
            .font(.title2.weight(.heavy))
            .frame(width: 50, height: 50)
            .background(Circle().stroke(color, lineWidth: 2))
            .contentShape(Circle())
            .padding(5)
    }
}

// 标题组件
struct HeaderView: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.orange)
            Text(title)
                .font(.title2.weight(.semibold))
            Spacer()
        }
        .padding(.bottom, 5)
    }
}

// 信息行组件
struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.medium))
        }
    }
}

// 数字样式扩展
extension Text {
    func boldNumberStyle(color: Color) -> some View {
        self
            .font(.system(.callout, design: .monospaced).weight(.bold))
            .foregroundColor(color)
            .padding(8)
            .background(Capsule().fill(color.opacity(0.1)))
    }
}
