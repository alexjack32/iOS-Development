//
//  PexelsVideoViewController.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 9/21/24.
//

import UIKit
import Combine
import AVFoundation

protocol VideoDownloadDelegate: AnyObject {
    func videoDownloadDidFinish(for indexPath: IndexPath, with videoURL: URL)
}

class PexelsVideoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {
    
    
    // Store the trait change registration token
    private var traitRegistrationToken: UITraitChangeRegistration?
    
    private var collectionView: UICollectionView!
    private var cancellables = Set<AnyCancellable>()
    private var videoURLs: [URL] = []
    private var currentPage = 1
    private let itemsPerPage = 5
    private var isLoading = false
    private var totalItems = 0
    
    // Dictionary to track ongoing download tasks
    private var downloadTasks: [URL: URLSessionDownloadTask] = [:]
    
    // NSCache to store AVPlayerItem for videos
    private var videoCache = NSCache<NSURL, NSURL>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
//        setupCollectionView()
//        fetchVideos(page: currentPage)
    }

    override func viewWillDisappear(_ animated: Bool) {
           super.viewWillDisappear(animated)

           // Unregister trait changes before the view disappears, to avoid capturing `self` in deinit
           if let token = traitRegistrationToken {
               unregisterForTraitChanges(token)
           }
       }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0 // No gap between cells
        layout.itemSize = CGSize(width: view.frame.width, height: view.frame.height) // Full screen size
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true // Enable paging for full-screen scroll effect
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self // Register prefetching data source
        collectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: VideoCollectionViewCell.reuseIdentifier)
        collectionView.register(IndicatorCell.self, forCellWithReuseIdentifier: IndicatorCell.reuseIdentifier)
//        view.addSubview(collectionView)
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
//            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
//        ])
    }
    
    func fetchVideos(page: Int) {
        guard !isLoading else { return }
        isLoading = true

        // Step 1: Show the loading cell
        collectionView.performBatchUpdates({
            self.collectionView.reloadData() // This ensures the loading cell appears
        }, completion: nil)

        // Simulate network fetch delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            // Step 2: Simulate data fetching
            let newVideos = (0..<self.itemsPerPage).map { URL(string: "https://example.com/video\($0)")! }
            let initialCount = self.videoURLs.count

            // Step 3: Append the fetched data
            self.videoURLs.append(contentsOf: newVideos)

            // Step 4: Perform batch updates to insert new items
            self.collectionView.performBatchUpdates({
                let indexPaths = (initialCount..<self.videoURLs.count).map { IndexPath(item: $0, section: 0) }
                self.collectionView.insertItems(at: indexPaths)
            }, completion: { _ in
                // Step 5: Remove the loading cell after appending
                self.isLoading = false
                self.collectionView.reloadData() // Reload to hide the loading cell
            })
        }
    }

    // UICollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return videoURLs.count
        //// Add 1 extra cell for loading indicator when loading is true
        return videoURLs.count + (isLoading ? 1 : 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == videoURLs.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IndicatorCell.reuseIdentifier, for: indexPath) as! IndicatorCell
            cell.indicator.startAnimating()
            print("loading cell <><")
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCollectionViewCell.reuseIdentifier, for: indexPath) as! VideoCollectionViewCell
            let videoURL = videoURLs[indexPath.item]
            
            // Log the current index and check if the cell is being dequeued correctly
            print("Configuring cell for index \(indexPath.item) with video URL: \(videoURL)")
            
            // Check if the video file URL is cached in NSCache
            if let cachedVideoURL = videoCache.object(forKey: videoURL as NSURL) as URL? {
                print("Using cached video file URL for index \(indexPath.item): \(cachedVideoURL)")
                // Configure the cell with the cached video URL
                cell.configure(with: cachedVideoURL)
            } else {
                // If the video is not cached, initiate the download
                print("Starting download for index \(indexPath.item) with video URL: \(videoURL)")
//                startDownload(for: videoURL, indexPath: indexPath) { [weak self] downloadedURL in
//                    guard let self = self else { return }
//                    
//                    // Cache the downloaded video URL
//                    self.videoCache.setObject(downloadedURL as NSURL, forKey: videoURL as NSURL)
//                    
//                    // Log after the video is downloaded and cached
//                    print("Downloaded and cached video for index \(indexPath.item): \(downloadedURL)")
//                    
//                    // Check if the cell is still visible and update it directly
//                    DispatchQueue.main.async {
//                        if let visibleCell = collectionView.cellForItem(at: indexPath) as? VideoCollectionViewCell {
//                            print("Updating visible cell for index \(indexPath.item)")
//                            visibleCell.configure(with: downloadedURL)
//                        }
//                    }
//                }
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Check if the cell is the loading indicator
        if indexPath.row == videoURLs.count && isLoading {
            let nextPage = (videoURLs.count / itemsPerPage) + 1
            fetchVideos(page: nextPage) // Trigger next page load
        } else if indexPath.item < videoURLs.count { // Ensure the index is within bounds
            // Handle video caching for regular cells
            let videoURL = videoURLs[indexPath.item]

            if let cachedVideoURL = videoCache.object(forKey: videoURL as NSURL) as URL? {
                if let videoCell = cell as? VideoCollectionViewCell {
                    print("Configuring video for index \(indexPath.item) in willDisplay")
                    videoCell.configure(with: cachedVideoURL)
                }
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let videoCell = cell as? VideoCollectionViewCell {
            print("Stopping video playback for index \(indexPath.item) as cell is no longer visible")
            videoCell.stopVideo()  // Custom method to stop video playback
        }
    }
    
    // MARK: Prefetching Data Source Methods
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if let maxIndex = indexPaths.max()?.item {
            if maxIndex >= videoURLs.count - 1 {
                currentPage += 1
                fetchVideos(page: currentPage)
            }
        }
        for indexPath in indexPaths {
            let videoURL = videoURLs[indexPath.item]
            
            // If the video is not already cached, start downloading it
            if videoCache.object(forKey: videoURL as NSURL) == nil {
//                startDownload(for: videoURL, indexPath: indexPath) { [weak self] downloadedURL in
//                    guard let self = self else { return }
//                    self.videoCache.setObject(downloadedURL as NSURL, forKey: videoURL as NSURL)
//                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        // Cancel the prefetching task when it's no longer needed
        for indexPath in indexPaths {
            let videoURL = videoURLs[indexPath.item]
            if let task = downloadTasks[videoURL] {
                task.cancel() // Cancel the download task
                downloadTasks.removeValue(forKey: videoURL) // Remove from tracking dictionary
                print("Cancelled download for \(videoURL)")
            }
        }
    }
    
    private func startDownload(for videoURL: URL, indexPath: IndexPath, completion: @escaping (URL) -> Void) {
        if downloadTasks[videoURL] != nil {
            print("Download already in progress for: \(videoURL)")
            return
        }

        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }

            let task = URLSession.shared.downloadTask(with: videoURL) { localURL, response, error in
                guard let localURL = localURL, error == nil else {
                    print("Error downloading video: \(String(describing: error))")
                    return
                }

                let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
                let destinationURL = cacheDirectory.appendingPathComponent(videoURL.lastPathComponent)

                do {
                    if FileManager.default.fileExists(atPath: destinationURL.path) {
                        try FileManager.default.removeItem(at: destinationURL)
                    }

                    try FileManager.default.moveItem(at: localURL, to: destinationURL)
                    print("Video successfully downloaded and moved to: \(destinationURL) for index \(indexPath.item)")

                    DispatchQueue.main.async {
                        completion(destinationURL)

                        // Force reload of the specific cell at the indexPath
                        self.collectionView.reloadItems(at: [indexPath])
                    }
                } catch {
                    print("Error moving video: \(error)")
                }

                DispatchQueue.main.async {
                    self.downloadTasks.removeValue(forKey: videoURL)
                }
            }

            task.resume()
            self.downloadTasks[videoURL] = task
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size
        let cellHeight = (indexPath.row == videoURLs.count && isLoading) ? 40 : (size.height / 3) // Adjust height for indicator
        return CGSize(width: size.width, height: cellHeight)
    }

}


