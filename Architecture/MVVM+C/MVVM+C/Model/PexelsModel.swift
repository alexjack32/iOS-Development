//
//  PexelsNetwork.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 9/13/24.
//

import Foundation

enum PexelsMediaItem: Hashable {
    case photo(PexelsPhoto)
    case video(PexelsVideo)

    func hash(into hasher: inout Hasher) {
        switch self {
        case .photo(let photo):
            hasher.combine(photo.id) // Ensure uniqueness
        case .video(let video):
            hasher.combine(video.id) // Ensure uniqueness
        }
    }

    static func == (lhs: PexelsMediaItem, rhs: PexelsMediaItem) -> Bool {
        switch (lhs, rhs) {
        case (.photo(let lhsPhoto), .photo(let rhsPhoto)):
            return lhsPhoto.id == rhsPhoto.id
        case (.video(let lhsVideo), .video(let rhsVideo)):
            return lhsVideo.id == rhsVideo.id
        default:
            return false
        }
    }
}

struct PexelsItem<T: Hashable & Decodable>: Decodable {
    let page: Int
    let perPage: Int
    let items: [T]
    let totalResults: Int
    let nextPage: String?

    enum CodingKeys: String, CodingKey {
        case page
        case perPage = "per_page"
        case photos
        case videos
        case totalResults = "total_results"
        case nextPage = "next_page"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.page = try container.decode(Int.self, forKey: .page)
        self.perPage = try container.decode(Int.self, forKey: .perPage)
        self.totalResults = try container.decode(Int.self, forKey: .totalResults)
        self.nextPage = try container.decodeIfPresent(String.self, forKey: .nextPage)
        
        if T.self == PexelsPhoto.self {
            self.items = try container.decode([T].self, forKey: .photos)
        } else if T.self == PexelsVideo.self {
            self.items = try container.decode([T].self, forKey: .videos)
        } else {
            self.items = []
        }
    }
}

struct PexelsPhoto: Hashable, Decodable {
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: PexelsPhoto, rhs: PexelsPhoto) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: Int
    let width: Int
    let height: Int
    let url: String
    let photographer: String
    let photographerURL: String
    let photographerID: Int
    let avgColor: String?
    let src: Src
    let liked: Bool
    let alt: String

    enum CodingKeys: String, CodingKey {
        case id, width, height, url, photographer
        case photographerURL = "photographer_url"
        case photographerID = "photographer_id"
        case avgColor = "avg_color"
        case src, liked, alt
    }
}

struct Src: Decodable, Equatable, Hashable {
    let original: String
    let large2x: String
    let large: String
    let medium: String
    let small: String
    let portrait: String
    let landscape: String
    let tiny: String
}

struct PexelsVideo: Hashable, Decodable {
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: PexelsVideo, rhs: PexelsVideo) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: Int
    let width: Int
    let height: Int
    let duration: Int
    let fullRes: String?
    let tags: [String]
    let url: String
    let image: String
    let avgColor: String?
    let user: User
    let videoFiles: [VideoFile]
    let videoPictures: [VideoPicture]

    enum CodingKeys: String, CodingKey {
        case id, width, height, duration, tags, url, image
        case fullRes = "full_res"
        case avgColor = "avg_color"
        case user, videoFiles = "video_files", videoPictures = "video_pictures"
    }
}

struct User: Decodable {
    let id: Int
    let name: String
    let url: String
}

struct VideoFile: Decodable {
    let id: Int
    let quality: String
    let fileType: String
    let width: Int
    let height: Int
    let fps: Double
    let link: String
    let size: Int

    enum CodingKeys: String, CodingKey {
        case id, quality, width, height, fps, link, size
        case fileType = "file_type"
    }
}

struct VideoPicture: Decodable {
    let id: Int
    let nr: Int
    let picture: String
}
