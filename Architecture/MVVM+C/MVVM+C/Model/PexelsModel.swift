import Foundation

//enum MediaType: Hashable {
//    case photo(PhotoDetails)
//    case video(VideoDetails)
//    
//    var id: Int {
//        switch self {
//        case .photo(let details):
////            return details.id
//        case .video(let details):
////            return details.id
//        }
//    }
//    
//    var url: String {
//        switch self {
//        case .photo(let details):
//            return details.src.large
//        case .video(let details):
//            return details.videoFiles.first?.link ?? ""
//        }
//    }
//    
//    // Add other properties or methods to access common elements
//}

// MARK: - UnifiedMediaResponse
struct UnifiedMediaResponse: Codable {
    let page, perPage: Int
    let totalResults: Int
    let nextPage: String?
    let media: [Media]

    enum CodingKeys: String, CodingKey {
        case page
        case perPage = "per_page"
        case totalResults = "total_results"
        case nextPage = "next_page"
        case media
    }
}

// MARK: - Media
struct Media: Codable {
    let id: Int
    let width, height: Int
    let url: String
    let photoDetails: PhotoDetails?
    let videoDetails: VideoDetails?

    enum CodingKeys: String, CodingKey {
        case id, width, height, url
        case photoDetails, videoDetails
    }
}

// MARK: - PhotoDetails
struct PhotoDetails: Codable {
    let photographer: String
    let photographerURL: String
    let photographerID: Int
    let avgColor: String
    let src: PhotoSource
    let liked: Bool
    let alt: String

    enum CodingKeys: String, CodingKey {
        case photographer
        case photographerURL = "photographer_url"
        case photographerID = "photographer_id"
        case avgColor = "avg_color"
        case src, liked, alt
    }
}

// MARK: - PhotoSource
struct PhotoSource: Codable {
    let original, large2x, large, medium, small, portrait, landscape, tiny: String
}

// MARK: - VideoDetails
struct VideoDetails: Codable {
    let user: User
    let videoFiles: [VideoFile]
    let videoPictures: [VideoPicture]

    enum CodingKeys: String, CodingKey {
        case user
        case videoFiles = "video_files"
        case videoPictures = "video_pictures"
    }
}

// MARK: - User
struct User: Codable {
    let id: Int
    let name: String
    let url: String
}

// MARK: - VideoFile
struct VideoFile: Codable {
    let id: Int
    let quality: Quality
    let fileType: FileType
    let width, height: Int
    let fps: Double
    let link: String
    let size: Int

    enum CodingKeys: String, CodingKey {
        case id, quality
        case fileType = "file_type"
        case width, height, fps, link, size
    }
}

enum FileType: String, Codable {
    case videoMp4 = "video/mp4"
}

enum Quality: String, Codable {
    case hd = "hd"
    case sd = "sd"
    case uhd = "uhd"
}

// MARK: - VideoPicture
struct VideoPicture: Codable {
    let id, nr: Int
    let picture: String
}
