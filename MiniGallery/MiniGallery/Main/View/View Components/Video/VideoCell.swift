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
    playerLayer?.videoGravity = .resizeAspectFill
    
    layer.insertSublayer(playerLayer!, at: 0)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(playerItemDidReachEnd(notification:)),
                                           name: Notification.Name.AVPlayerItemDidPlayToEndTime,
                                           object: player?.currentItem)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(didReceiveOrientationChangeNotification(notification:)),
                                           name: .UIDeviceOrientationDidChange,
                                           object: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    changePlayerLayerFrame()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc private func playerItemDidReachEnd(notification: Notification) {
    if let item = notification.object as? AVPlayerItem,
      let currentItem = player?.currentItem,
      item == currentItem {
      item.seek(to: kCMTimeZero, completionHandler: nil)
    }
  }
  
  @objc private func didReceiveOrientationChangeNotification(notification: Notification) {
//    changePlayerLayerFrame()
  }
  
  func stopPlaying() {
    player?.pause()
  }
  
  func startPlaying() {
    player?.play()
  }
  
  private func changePlayerLayerFrame() {
    if UIDevice.current.orientation.isLandscape {
      playerLayer?.frame = CGRect(x: bounds.width / 2 - 50, y: 20, width: 100, height: 100)
    } else {
      playerLayer?.frame = bounds
    }
  }
}
