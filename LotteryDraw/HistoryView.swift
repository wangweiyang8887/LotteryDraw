import SwiftUI

struct HistoryView: View {
    @ObservedObject var recordManager: LotteryRecordManager
    let selectedType: LotteryType
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(recordManager.getRecords(for: selectedType)) { record in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            // 号码显示
                            HStack(spacing: 6) {
                                ForEach(record.numbers.indices, id: \.self) { index in
                                    NumberBall(
                                        number: record.numbers[index],
                                        type: record.type,
                                        index: index
                                    )
                                }
                            }
                            
                            Spacer()
                            
                            // 收藏按钮
                            Button(action: {
                                recordManager.toggleFavorite(for: record.id)
                            }) {
                                Image(systemName: record.isFavorite ? "heart.fill" : "heart")
                                    .foregroundColor(record.isFavorite ? .red : .gray)
                                    .font(.title3)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        HStack {
                            Text(record.formattedDate)
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            if record.isFavorite {
                                Image(systemName: "star.fill")
                                    .font(.caption)
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("\(selectedType.rawValue)历史记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("清空") {
                        recordManager.clearRecords(for: selectedType)
                    }
                }
            }
        }
    }
}

// 号码球视图 (与 LotteryResultView 中的完全相同)
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
        Text(String(format: "%02d", number))
            .font(.system(size: 17, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .frame(width: 34, height: 34)
            .background(
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                ballColor.opacity(0.8),
                                ballColor
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: ballColor.opacity(0.5), radius: 2, x: 0, y: 2)
            )
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .overlay(
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0.5),
                                .clear
                            ]),
                            startPoint: .topLeading,
                            endPoint: .center
                        )
                    )
                    .padding(8)
            )
    }
} 
