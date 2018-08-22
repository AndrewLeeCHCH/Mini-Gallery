//
//  VideoCollectionView.swift
//  MiniGallery
//
//  Created by Jinyao Li on 8/20/18.
//  Copyright © 2018 Jinyao Li. All rights reserved.
//

import UIKit
import AVFoundation

public final class VideoCollectionView: UICollectionView, MGCollectionView {
  
  // MARK: -Variables
  
  weak public var eventDelegate: MGCollectionViewDelegate?
  
  internal let cellId = "cellId"
  
  internal var urls: [URL] = [] {
    didSet {
      DispatchQueue.main.async {
        self.reloadData()
      }
    }
  }
  
  internal var indexPathBeforeChangingOrientation: IndexPath?
  
  // MARK: -Lifecycle
  
  required public init() {
    
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
  
  public func updateData<T>(data: [T]) {
    guard let urls = data as? [URL] else {
      return
    }
    self.urls = urls
  }
  
  public func prepareForOrientationChange() {
    var index = Int(floor(contentOffset.x / UIScreen.main.bounds.width))
    index = index < 0 ? 0 : index >= urls.count ? urls.count - 1 : index
    
    indexPathBeforeChangingOrientation = IndexPath(item: index, section: 0)
  }
  
  public func rescrollForOrientationChange() {
    guard let indexPathBeforeChangingOrientation = indexPathBeforeChangingOrientation else {
      return
    }
    DispatchQueue.main.async {
      self.reloadItems(at: [indexPathBeforeChangingOrientation])
      self.scrollToItem(at: indexPathBeforeChangingOrientation, at: .centeredHorizontally, animated: false)
    }
  }
  
  // MARK: -Helper
  
  internal func calculateCurrentIndex() -> Int {
    var index = Int(floor(contentOffset.x / UIScreen.main.bounds.width))
    index = index < 0 ? 0 : index >= urls.count ? urls.count - 1 : index
    return index
  }
}

extension VideoCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return urls.count
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! VideoCell
    
    cell.url = urls[indexPath.item]
    return cell
  }
  
  public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    if let cell = cell as? VideoCell {
      cell.startPlaying()
    }
  }
  
  public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    if let cell = cell as? VideoCell {
      cell.stopPlaying()
    }
  }
}

extension VideoCollectionView: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if UIDevice.current.orientation.isLandscape {
      return CGSize(width: UIScreen.main.bounds.width, height: 300)
    }
    
    return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
  }
  
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets.zero
  }
}

extension VideoCollectionView: UIScrollViewDelegate {
  public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    visibleCells.forEach { cell in
      if let cell = cell as? VideoCell {
        cell.startPlaying()
      }
    }
  }
  
  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    visibleCells.forEach { cell in
      if let cell = cell as? VideoCell {
        cell.startPlaying()
      }
    }
    eventDelegate?.collectionView(self, didScrollTo: calculateCurrentIndex())
  }
}

