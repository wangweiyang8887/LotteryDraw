//
//  Server.swift
//  LotteryDraw
//
//  Created by evan on 2025/2/18.
//

import Foundation

struct LotteryResult : Codable {
    var result: LotteryModel
}

struct Server {
    static let shared = Server()
    
    private let lottery_url = "https://apis.juhe.cn/lottery/query"
    func getLottery(with id: String, completion: @escaping (Result<LotteryModel, Error>) -> Void) {
        let parameters = [ "lottery_id":id, "lottery_no":"", "key":"f7359c92478f397e465867fc24a550a2" ]
        let urlstring = lottery_url.combinedUrlIfNeeded(with: parameters)
        let url = URL(string: urlstring)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            if let result = LotteryResult.decode(from: data!)?.result, result.lottery_id.trimmedNilIfEmpty != nil {
                completion(.success(result))
            } else {
                completion(.failure(NSError()))
            }
        }
        task.resume()
    }
}

extension String {
    func combinedUrlIfNeeded(with parameters: [String:Any]) -> String {
        let result = parameters.map { return $0 + "=" + "\($1)" + "&" }.joined().dropLast()
        return result.isEmpty ? self : self + "?" + result
    }
    
    func trimmed() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var trimmedNilIfEmpty: String? {
        let result = trimmed()
        return result.isEmpty ? nil : result
    }
}
