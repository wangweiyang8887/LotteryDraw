import Foundation

// 摇号记录模型
struct LotteryRecord: Identifiable, Codable {
    let id: UUID
    let type: LotteryType
    let numbers: [Int]
    let timestamp: Date
    var isFavorite: Bool  // 添加收藏标记
    
    // 添加一个计算属性来格式化时间
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "MM月dd日 HH:mm:ss"
        return formatter.string(from: timestamp)
    }
    
    init(type: LotteryType, numbers: [Int], isFavorite: Bool = false) {
        self.id = UUID()
        self.type = type
        self.numbers = numbers
        self.timestamp = Date()
        self.isFavorite = isFavorite
    }
}

// 扩展LotteryType以支持Codable
extension LotteryType: Codable {
    enum CodingKeys: String, CodingKey {
        case rawValue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawValue = try container.decode(String.self, forKey: .rawValue)
        self = LotteryType(rawValue: rawValue) ?? .doubleColorBall
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rawValue, forKey: .rawValue)
    }
} 

class LotteryModel : Codable {
    let lottery_id: String //ssq
    let lottery_name: String // 彩种 e.双色球
    let lottery_res: String // 结果 e. "01,02,03,04,05,06,07"
    let lottery_no: String // 期号 e. "25017"
    let lottery_date: String // 日期 e. "2025-02-018"
    let lottery_exdate: String // 兑奖截止日期 e. "2025-04-18"
    let lottery_sale_amount: String // 销售额
    let lottery_pool_amount: String // 奖池
    let lottery_prize: [Price]
    
    struct Price : Codable {
        let prize_name: String // 中奖类型 e. 一等奖
        let prize_num: String // 中奖数量
        let prize_amount: String // 中奖金额
        let prize_require: String // 中奖条件
    }
}

