import Foundation

// 用于 App 与 Widget 共享的数据
struct SharedLotteryData {
    static let appGroupID = "group.com.lotterydraw.lottery"
    static let widgetKind = "com.lotterydraw.lottery.widget"
    
    static func saveLatestNumbers(_ numbers: [Int], type: LotteryType) {
        let userDefaults = UserDefaults(suiteName: appGroupID)
        let data = try? JSONEncoder().encode(numbers)
        userDefaults?.set(data, forKey: "latest_numbers_\(type.rawValue)")
        userDefaults?.set(Date(), forKey: "latest_update_time")
    }
    
    static func getLatestNumbers(for type: LotteryType) -> [Int]? {
        let userDefaults = UserDefaults(suiteName: appGroupID)
        guard let data = userDefaults?.data(forKey: "latest_numbers_\(type.rawValue)"),
              let numbers = try? JSONDecoder().decode([Int].self, from: data) else {
            return nil
        }
        return numbers
    }
} 
