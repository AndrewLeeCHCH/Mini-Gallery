//
//  VideoCell.swift
//  MiniGallery
//
//  Created by Jinyao Li on 8/20/18.
//  Copyright © 2018 Jinyao Li. All rights reserved.
//

import UIKit
import AVFoundation

final internal class VideoCell: UICollectionViewCell {
  
  // MARK: - Variables
  
  internal var url: URL? {
    didSet {
      if let url = url {
        DispatchQueue.main.async {
          self.player?.replaceCurrentItem(with: AVPlayerItem(url: url))
        }
      }
    }
  }
  
  internal var player: AVPlayer?
  internal var playerLayer: AVPlayerLayer?
  
  // MARK: - Lifecycle
  
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
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override public func layoutSubviews() {
    super.layoutSubviews()
    
    changePlayerLayerFrame()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - Listeners
  
  @objc internal func playerItemDidReachEnd(notification: Notification) {
    if let item = notification.object as? AVPlayerItem {
      item.seek(to: kCMTimeZero, completionHandler: nil)
    }
  }

  internal func stopPlaying() {
    player?.pause()
  }
  
  internal func startPlaying() {
    player?.play()
  }
  
  // MARK: - Helper
  
  internal func changePlayerLayerFrame() {
    if UIDevice.current.orientation.isLandscape {
      playerLayer?.frame = CGRect(x: bounds.midX - 50, y: 20, width: 100, height: 100)
    } else if UIDevice.current.orientation.isPortrait {
      playerLayer?.frame = bounds
    }
  }
}
