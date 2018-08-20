//
//  VideoCollectionView.swift
//  MiniGallery
//
//  Created by Jinyao Li on 8/20/18.
//  Copyright © 2018 Jinyao Li. All rights reserved.
//

import UIKit

protocol CollectionView {
  func updateData<T>(data: [T])
  func rescrollForOrientationChange()
}

final class VideoCollectionView: UICollectionView, CollectionView {
  
  // MARK: -Variables
  
  let cellId = "cellId"
  
  private var posts: [Post] = [] {
    didSet {
      DispatchQueue.main.async {
        self.reloadData()
      }
    }
  }
  
  // MARK: -Initialization
  
  required init() {
    
    // Create horizontal-scrolling UICollectionView
    let collectionViewFlowLayout = UICollectionViewFlowLayout();
    collectionViewFlowLayout.scrollDirection = .horizontal
    super.init(frame: CGRect.zero, collectionViewLayout: collectionViewFlowLayout)
    
    dataSource = self
    delegate = self
    
    register(VideoCell.self, forCellWithReuseIdentifier: cellId)
    isPagingEnabled = true
    showsHorizontalScrollIndicator = false
    backgroundColor = .white
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func rescrollForOrientationChange() {
    var index = Int(floor(contentOffset.x / UIScreen.main.bounds.width))
    index = index < 0 ? 0 : index >= self.posts.count ? self.posts.count - 1 : index
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
      self.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: false)
    })
  }
  
  func updateData<T>(data: [T]) {
    guard let posts = data as? [Post] else {
      return
    }
    self.posts = posts
  }
}

extension VideoCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return posts.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! VideoCell
    
    cell.videoUrlString = posts[indexPath.item].videoUrl
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    if let cell = cell as? VideoCell {
      cell.startPlaying()
    }
  }
  
}

extension VideoCollectionView: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if UIDevice.current.orientation.isLandscape {
      return CGSize(width: UIScreen.main.bounds.width, height: 300)
    }
    
    return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  
  func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    if let cell = cell as? VideoCell {
      cell.stopPlaying()
    }
  }
}

extension VideoCollectionView: UIScrollViewDelegate {
  func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    visibleCells.forEach { cell in
      if let cell = cell as? VideoCell {
        cell.startPlaying()
      }
    }
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    visibleCells.forEach { cell in
      if let cell = cell as? VideoCell {
        cell.startPlaying()
      }
    }
  }
}

