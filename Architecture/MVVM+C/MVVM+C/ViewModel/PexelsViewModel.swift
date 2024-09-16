//
//  PexelsNetwork.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 9/13/24.
//

import Foundation
import Combine
import AVKit

class PexelsViewModel {
    @Published var mediaItems: [PexelsMediaItem] = []
    var mediaItemsSubject = PassthroughSubject<[PexelsMediaItem], Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    private var currentPage: Int = 1
    private var perPage: Int = 2
    private var isFetching: Bool = false  // Flag to track fetching state
    private var hasMoreMedia: Bool = true
    
    private let mediaCache = MediaCache.shared

    // Initial media fetch (e.g., when the view first loads)
    func fetchMedia() {
        guard !isFetching else { return }  // Prevent multiple fetches
        isFetching = true
        currentPage = 1
        mediaItems.removeAll() // Remove previous items to start fresh
        fetchMediaPage(page: currentPage)
    }
    
    // Fetch additional media (e.g., when scrolling to the end of the list)
    func fetchMoreMedia() {
        guard !isFetching && hasMoreMedia else { return }  // Prevent multiple fetches
        isFetching = true
        currentPage += 1
        fetchMediaPage(page: currentPage)
    }
    
    private func fetchMediaPage(page: Int) {
        let photosPublisher = fetchPhotos(page: page, perPage: perPage)
        let videosPublisher = fetchVideos(page: page, perPage: perPage)
        
        Publishers.Zip(photosPublisher, videosPublisher)
            .map { photos, videos in
                return photos + videos
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] combinedMediaItems in
                guard let self = self else { return }
                
                if combinedMediaItems.isEmpty {
                    self.hasMoreMedia = false
                } else {
                    self.mediaItems.append(contentsOf: combinedMediaItems)
                    self.mediaItemsSubject.send(self.mediaItems)
                }
                
                self.isFetching = false  // Reset the fetching flag
            }
            .store(in: &cancellables)
    }
    
    private func fetchPhotos(page: Int, perPage: Int) -> AnyPublisher<[PexelsMediaItem], Never> {
        return Future<[PexelsMediaItem], Never> { promise in
            PexelsNetwork.shared.request(endpoint: .photos(page: page, perPage: perPage)) { [weak self] (result: Result<PexelsItem<PexelsPhoto>, Error>) in
                guard let self = self else { return }
                
                switch result {
                case .success(let items):
                    let mediaItems = items.items.map { item -> PexelsMediaItem in
                        let mediaItem = PexelsMediaItem.photo(item)
                        // Cache the image
                        if let url = URL(string: item.src.original) {
                            self.cacheImage(from: url)
                        }
                        return mediaItem
                    }
                    promise(.success(mediaItems))
                case .failure(let error):
                    print("Error fetching photos: \(error)")
                    promise(.success([]))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func fetchVideos(page: Int, perPage: Int) -> AnyPublisher<[PexelsMediaItem], Never> {
        return Future<[PexelsMediaItem], Never> { promise in
            PexelsNetwork.shared.request(endpoint: .videos(page: page, perPage: perPage)) { [weak self] (result: Result<PexelsItem<PexelsVideo>, Error>) in
                guard let self = self else { return }
                
                switch result {
                case .success(let items):
                    let mediaItems = items.items.map { item -> PexelsMediaItem in
                        let mediaItem = PexelsMediaItem.video(item)
                        // Cache the video
                        if let url = URL(string: item.videoFiles.first?.link ?? "") {
                            self.cacheVideo(from: url)
                        }
                        return mediaItem
                    }
                    promise(.success(mediaItems))
                case .failure(let error):
                    print("Error fetching videos: \(error)")
                    promise(.success([]))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func cacheImage(from url: URL) {
        let nsUrl = url as NSURL
        if mediaCache.cachedImage(for: nsUrl) == nil {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    self.mediaCache.cacheImage(image, for: nsUrl)
                }
            }.resume()
        }
    }
    
    private func cacheVideo(from url: URL) {
        let nsUrl = url as NSURL
        if mediaCache.cachedVideo(for: nsUrl) == nil {
            let playerItem = AVPlayerItem(url: url)
            self.mediaCache.cacheVideo(playerItem, for: nsUrl)
        }
    }
}

class MediaCache {
    static let shared = MediaCache()

    private init() {}
    
    private let imageCache = NSCache<NSURL, UIImage>()
    private let videoCache = NSCache<NSURL, AVPlayerItem>()
    
    func cacheImage(_ image: UIImage, for url: NSURL) {
        imageCache.setObject(image, forKey: url)
    }
    
    func cachedImage(for url: NSURL) -> UIImage? {
        return imageCache.object(forKey: url)
    }
    
    func cacheVideo(_ playerItem: AVPlayerItem, for url: NSURL) {
        videoCache.setObject(playerItem, forKey: url)
    }
    
    func cachedVideo(for url: NSURL) -> AVPlayerItem? {
        return videoCache.object(forKey: url)
    }
}
