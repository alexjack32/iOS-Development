//
//  VideoManager.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 9/16/24.
//

import AVKit

class VideoManager {
    static let shared = VideoManager()
    
    private var players: [URL: AVPlayer] = [:]
    
    func player(for url: URL) -> AVPlayer {
        if let player = players[url] {
            return player
        } else {
            let player = AVPlayer(url: url)
            players[url] = player
            return player
        }
    }
    
    func cleanupPlayer(for url: URL) {
        if let player = players[url] {
            player.pause()
            player.replaceCurrentItem(with: nil)
            players.removeValue(forKey: url)
        }
    }
    
    func pauseAll() {
        for player in players.values {
            player.pause()
        }
    }
}
