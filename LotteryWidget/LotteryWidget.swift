import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> LotteryEntry {
        LotteryEntry(date: Date(), numbers: [1, 2, 3, 4, 5, 6, 7], type: .doubleColorBall)
    }

    func getSnapshot(in context: Context, completion: @escaping (LotteryEntry) -> ()) {
        let entry = LotteryEntry(
            date: Date(),
            numbers: SharedLotteryData.getLatestNumbers(for: .doubleColorBall) ?? [1, 2, 3, 4, 5, 6, 7],
            type: .doubleColorBall
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entries = [
            LotteryEntry(
                date: Date(),
                numbers: SharedLotteryData.getLatestNumbers(for: .doubleColorBall) ?? [1, 2, 3, 4, 5, 6, 7],
                type: .doubleColorBall
            )
        ]
        let timeline = Timeline(entries: entries, policy: .after(.now.advanced(by: 3600)))
        completion(timeline)
    }
}

struct LotteryEntry: TimelineEntry {
    let date: Date
    let numbers: [Int]
    let type: LotteryType
}

struct LotteryWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("双色球")
                    .font(.headline)
                Spacer()
                Text(entry.date, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 6) {
                ForEach(entry.numbers.indices, id: \.self) { index in
                    NumberBall(
                        number: entry.numbers[index],
                        type: entry.type,
                        index: index
                    )
                    .frame(width: 28, height: 28) // Widget中球稍微小一点
                }
            }
            
            Button(intent: GenerateNumbersIntent()) {
                Label("生成号码", systemImage: "dice")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

struct LotteryWidget: Widget {
    let kind: String = SharedLotteryData.widgetKind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            LotteryWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("彩票号码")
        .description("显示最近一次生成的号码")
        .supportedFamilies([.systemMedium])
    }
}
