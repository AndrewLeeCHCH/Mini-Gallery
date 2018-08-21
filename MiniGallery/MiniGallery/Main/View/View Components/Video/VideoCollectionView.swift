//
//  VideoCollectionView.swift
//  MiniGallery
//
//  Created by Jinyao Li on 8/20/18.
//  Copyright © 2018 Jinyao Li. All rights reserved.
//

import UIKit

final class VideoCollectionView: UICollectionView, MGCollectionView {
  
  // MARK: -Variables
  
  weak var eventDelegate: MGCollectionViewDelegate?
  
  let cellId = "cellId"
  
  private var posts: [Post] = [] {
    didSet {
      DispatchQueue.main.async {
        self.reloadData()
      }
    }
  }
  
  private var indexPathBeforeChangingOrientation: IndexPath?
  
  // MARK: -Lifecycle
  
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
  
  // MARK: -MGCollectionView functions
  
  func updateData<T>(data: [T]) {
    guard let posts = data as? [Post] else {
      return
    }
    self.posts = posts
  }
  
  func prepareForOrientationChange() {
    var index = Int(floor(contentOffset.x / UIScreen.main.bounds.width))
    index = index < 0 ? 0 : index >= posts.count ? posts.count - 1 : index
    
    indexPathBeforeChangingOrientation = IndexPath(item: index, section: 0)
  }
  
  func rescrollForOrientationChange() {
    guard let indexPathBeforeChangingOrientation = indexPathBeforeChangingOrientation else {
      return
    }
    DispatchQueue.main.async {
      self.reloadItems(at: [indexPathBeforeChangingOrientation])
      self.scrollToItem(at: indexPathBeforeChangingOrientation, at: .centeredHorizontally, animated: false)
    }
  }
  
  // MARK: -Helper
  
  private func calculateCurrentIndex() -> Int {
    var index = Int(floor(contentOffset.x / UIScreen.main.bounds.width))
    index = index < 0 ? 0 : index >= posts.count ? posts.count - 1 : index
    return index
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
  
  func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    if let cell = cell as? VideoCell {
      cell.stopPlaying()
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
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets.zero
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
    eventDelegate?.collectionView(self, didScrollTo: calculateCurrentIndex())
  }
}

