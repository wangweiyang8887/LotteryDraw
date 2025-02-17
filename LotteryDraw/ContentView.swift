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
                MultiRandomNumberView()
                    .tabItem {
                        Label("彩票摇号", systemImage: "ticket.fill")
                    }
                
                LuckyNumberView()
                    .tabItem {
                        Label("幸运数字", systemImage: "star.fill")
                    }
            }
        }
        .padding()
    }
}
