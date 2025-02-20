import AppIntents
import WidgetKit

struct GenerateNumbersIntent: AppIntent {
    static var title: LocalizedStringResource = "生成随机号码"
    
    func perform() async throws -> some IntentResult {
        // 生成随机号码
        var numbers: [Int] = []
        // 生成6个红球
        while numbers.count < 6 {
            let number = Int.random(in: 1...33)
            if !numbers.contains(number) {
                numbers.append(number)
            }
        }
        numbers.sort()
        // 生成1个蓝球
        numbers.append(Int.random(in: 1...16))
        
        // 保存到共享存储
        SharedLotteryData.saveLatestNumbers(numbers, type: .doubleColorBall)
        
        // 刷新 widget
        WidgetCenter.shared.reloadTimelines(ofKind: SharedLotteryData.widgetKind)
        
        return .result()
    }
} 