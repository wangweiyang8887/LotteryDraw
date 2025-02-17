import Foundation

// 摇号记录模型
struct LotteryRecord: Identifiable, Codable {
    let id: UUID
    let type: LotteryType
    let numbers: [Int]
    let timestamp: Date
    var isFavorite: Bool  // 添加收藏标记
    
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