import Combine
import Foundation

class PexelsViewModel: ObservableObject {
    @Published var mediaItems: [Media] = []
    @Published var error: Error?
    
    private var cancellables = Set<AnyCancellable>()
    private let service = PexelsNetwork()
    
//    func fetchMedia(query: String, page: Int = 1, perPage: Int = 10) {
//        Publishers.Zip(
//            service.fetchPhotos(query: query, page: page, perPage: perPage),
//            service.fetchVideos(query: query, page: page, perPage: perPage)
//        )
//        .map { photoResponse, videoResponse in
//            // Combine the photo and video items into a unified media array
//            let photoMedia = photoResponse.items.map { Media(from: $0 as! Decoder) }
//            let videoMedia = videoResponse.items.map { Media(from: $0 as! Decoder) }
//            
//            return photoMedia + videoMedia // Combine photo and video media
//        }
//        .sink(receiveCompletion: { completion in
//            if case .failure(let error) = completion {
//                self.error = error
//            }
//        }, receiveValue: { [weak self] mediaItems in
//            self?.mediaItems = mediaItems
//        })
//        .store(in: &cancellables)
//    }
}
