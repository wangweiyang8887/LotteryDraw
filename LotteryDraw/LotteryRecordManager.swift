import Foundation
import WidgetKit

class LotteryRecordManager: ObservableObject {
    @Published private(set) var records: [LotteryRecord] = []
    private let saveKey = "LotteryRecords"
    
    init() {
        loadRecords()
    }
    
    func addRecord(_ record: LotteryRecord) {
        // 验证数据是否有效
        guard isValidRecord(record) else { return }
        
        records.insert(record, at: 0) // 新记录插入到最前面
        saveRecords()
        
        // 更新 Widget 显示
        SharedLotteryData.saveLatestNumbers(record.numbers, type: record.type)
        WidgetCenter.shared.reloadTimelines(ofKind: SharedLotteryData.widgetKind)
    }
    
    private func isValidRecord(_ record: LotteryRecord) -> Bool {
        // 检查数字数量是否正确
        guard record.numbers.count == record.type.numberCount else { return false }
        
        // 检查数字范围是否正确
        switch record.type {
        case .doubleColorBall:
            // 检查红球
            let redBalls = Array(record.numbers.prefix(6))
            guard redBalls.allSatisfy({ (1...33).contains($0) }) else { return false }
            // 检查蓝球
            guard (1...16).contains(record.numbers[6]) else { return false }
            // 检查红球是否有重复
            guard Set(redBalls).count == 6 else { return false }
            
        case .bigLotto:
            // 检查前区
            let frontNumbers = Array(record.numbers.prefix(5))
            guard frontNumbers.allSatisfy({ (1...35).contains($0) }) else { return false }
            // 检查后区
            let backNumbers = Array(record.numbers.suffix(2))
            guard backNumbers.allSatisfy({ (1...12).contains($0) }) else { return false }
            // 检查是否有重复
            guard Set(frontNumbers).count == 5 && Set(backNumbers).count == 2 else { return false }
            
        case .lottery3D, .arrangement3:
            guard record.numbers.allSatisfy({ (0...9).contains($0) }) else { return false }
            guard record.numbers.count == 3 else { return false }
            
        case .arrangement5:
            guard record.numbers.allSatisfy({ (0...9).contains($0) }) else { return false }
            guard record.numbers.count == 5 else { return false }
        }
        
        return true
    }
    
    func clearRecords(for type: LotteryType? = nil) {
        if let type = type {
            records.removeAll { $0.type == type }
        } else {
            records.removeAll()
        }
        saveRecords()
    }
    
    private func loadRecords() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decodedRecords = try? JSONDecoder().decode([LotteryRecord].self, from: data) {
            // 过滤掉无效记录
            records = decodedRecords.filter { isValidRecord($0) }
        }
    }
    
    private func saveRecords() {
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    func toggleFavorite(for id: UUID) {
        if let index = records.firstIndex(where: { $0.id == id }) {
            var updatedRecord = records[index]
            updatedRecord.isFavorite.toggle()
            records[index] = updatedRecord
            saveRecords()
        }
    }
    
    func getRecords(for type: LotteryType) -> [LotteryRecord] {
        records
            .filter { $0.type == type }
            .sorted { (record1, record2) in
                // 先按收藏状态排序，再按时间倒序排序
                if record1.isFavorite != record2.isFavorite {
                    return record1.isFavorite
                }
                return record1.timestamp > record2.timestamp
            }
    }
} 