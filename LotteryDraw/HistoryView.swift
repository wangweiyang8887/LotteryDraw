import SwiftUI

struct HistoryView: View {
    @ObservedObject var recordManager: LotteryRecordManager
    let selectedType: LotteryType
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(recordManager.getRecords(for: selectedType)) { record in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            // 号码显示
                            HStack(spacing: 8) {
                                ForEach(record.numbers.indices, id: \.self) { index in
                                    Text(formatNumber(record.numbers[index], index: index, type: record.type))
                                        .font(.system(.body, design: .rounded))
                                        .foregroundColor(numberColor(for: index, type: record.type))
                                        .frame(width: 30, height: 30)
                                        .background(
                                            Circle()
                                                .fill(.gray.opacity(0.1))
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
                            Text(record.timestamp.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            if record.isFavorite {
                                Image(systemName: "star.fill")
                                    .font(.caption)
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                    .contextMenu {
                        Button(action: {
                            recordManager.toggleFavorite(for: record.id)
                        }) {
                            Label(
                                record.isFavorite ? "取消收藏" : "收藏",
                                systemImage: record.isFavorite ? "heart.slash" : "heart.fill"
                            )
                        }
                    }
                }
            }
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
    
    private func formatNumber(_ number: Int, index: Int, type: LotteryType) -> String {
        switch type {
        case .doubleColorBall, .bigLotto:
            return String(format: "%02d", number)
        case .lottery3D, .arrangement3, .arrangement5:
            return String(format: "%d", number)
        }
    }
    
    private func numberColor(for index: Int, type: LotteryType) -> Color {
        switch type {
        case .doubleColorBall:
            return index == 6 ? .blue : .red
        case .bigLotto:
            return index >= 5 ? .blue : .red
        case .lottery3D:
            return .purple
        case .arrangement3:
            return .orange
        case .arrangement5:
            return .green
        }
    }
} 
