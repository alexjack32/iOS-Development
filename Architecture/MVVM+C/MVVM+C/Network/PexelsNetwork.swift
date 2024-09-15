//
//  PexelsNetwork.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 9/13/24.
// vuXNgk6kYpCbuhCyh05EBHpHUUMumigHZTfx3QpyMg9onUiHGbmHmuLN
//
//
//

import Combine
import Foundation

class PexelsNetwork {
    static let shared = PexelsNetwork()
    private let apiKey = Bundle.main.object(forInfoDictionaryKey: "PexelsAPIKey") as? String
    
    func request<T: Hashable & Decodable>(
        endpoint: PexelsEndpoint,
        completion: @escaping (Result<PexelsItem<T>, Error>) -> Void
    ) {
        guard let apiKey = apiKey else {
            completion(.failure(NSError(domain: "Missing API Key", code: 0, userInfo: nil)))
            return
        }
        
        var urlRequest = URLRequest(url: endpoint.url)
        urlRequest.addValue(apiKey, forHTTPHeaderField: "Authorization")
        urlRequest.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(PexelsItem<T>.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

enum PexelsEndpoint {
    case photos(page: Int, perPage: Int)
    case videos(page: Int, perPage: Int)
    
    var url: URL {
        switch self {
        case .photos(let page, let perPage):
            return URL(string: "https://api.pexels.com/v1/curated?page=\(page)&per_page=\(perPage)")!
        case .videos(let page, let perPage):
            return URL(string: "https://api.pexels.com/videos/popular?page=\(page)&per_page=\(perPage)")!
        }
    }
}
