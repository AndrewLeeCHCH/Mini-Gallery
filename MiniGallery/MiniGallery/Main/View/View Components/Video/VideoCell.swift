//
//  VideoCell.swift
//  MiniGallery
//
//  Created by Jinyao Li on 8/20/18.
//  Copyright © 2018 Jinyao Li. All rights reserved.
//

import UIKit
import AVFoundation

final class VideoCell: UICollectionViewCell {
  
  var videoUrlString: String = "" {
    didSet {
      NetworkManager.shared.getVideoURLFrom(videoUrlString) { url in
        // Make sure url should be the same as current videoUrlString
        if let _ = url.absoluteString.range(of: self.videoUrlString.split(separator: "/")[3]) {
          DispatchQueue.main.async {
            self.player?.replaceCurrentItem(with: AVPlayerItem(url: url))
          }
        }
      }
    }
  }
  
  var player: AVPlayer?
  var playerLayer: AVPlayerLayer?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    player = AVPlayer(playerItem: nil)
    player?.actionAtItemEnd = .none
    
    playerLayer = AVPlayerLayer(player: player)
    playerLayer?.videoGravity = .resize
    
    layer.insertSublayer(playerLayer!, at: 0)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(playerItemDidReachEnd(notification:)),
                                           name: Notification.Name.AVPlayerItemDidPlayToEndTime,
                                           object: player?.currentItem)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    if UIDevice.current.orientation.isLandscape {
      playerLayer?.frame = CGRect(x: UIScreen.main.bounds.width / 2 - 50, y: 20, width: 50, height: 50)
    } else {
      playerLayer?.frame = bounds
    }
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc func playerItemDidReachEnd(notification: Notification) {
    if let item = notification.object as? AVPlayerItem,
      let currentItem = player?.currentItem,
      item == currentItem {
      item.seek(to: kCMTimeZero, completionHandler: nil)
    }
  }
  
  func stopPlaying() {
    player?.pause()
  }
  
  func startPlaying() {
    player?.play()
  }
}
