//
//  PexelsNetwork.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 9/13/24.
//

import Combine
import Foundation

class PexelsNetwork {
    private let apiKey = "vuXNgk6kYpCbuhCyh05EBHpHUUMumigHZTfx3QpyMg9onUiHGbmHmuLN"
    private let baseURL = "https://api.pexels.com/v1/"
    private let videoBaseURL = "https://api.pexels.com/videos/"
    
    func fetchPhotos(query: String, page: Int = 1, perPage: Int = 10) -> AnyPublisher<PexelsResponse<PhotoDetails>, Error> {
        let url = URL(string: "\(baseURL)search?query=\(query)&page=\(page)&per_page=\(perPage)")!
        return fetch(url: url)
    }
    
    func fetchVideos(query: String, page: Int = 1, perPage: Int = 10) -> AnyPublisher<PexelsResponse<VideoDetails>, Error> {
        let url = URL(string: "\(videoBaseURL)search?query=\(query)&page=\(page)&per_page=\(perPage)")!
        return fetch(url: url)
    }
    
    private func fetch<T: Decodable>(url: URL) -> AnyPublisher<PexelsResponse<T>, Error> {
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .decode(type: PexelsResponse<T>.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

    struct PexelsResponse<T: Decodable>: Decodable {
        let page: Int
        let perPage: Int
        let items: [T]
        let totalResults: Int
        let nextPage: String?

        enum CodingKeys: String, CodingKey {
            case page
            case perPage = "per_page"
            case items = "photos" // For photos; adjust for videos if needed
            case totalResults = "total_results"
            case nextPage = "next_page"
        }
    }
