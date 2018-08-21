//
//  ImageCollectionView.swift
//  PinOn
//
//  Created by Jinyao Li on 8/20/18.
//  Copyright (c) 2017-present, PinOn, Inc. All rights reserved.
//

import UIKit

final class ImageCollectionView: UICollectionView, MGCollectionView {
  
  // MARK: - Variables
  
  weak var eventDelegate: MGCollectionViewDelegate?
  
  private var posts: [Post] = [] {
    didSet {
      DispatchQueue.main.async {
        self.reloadData()
        guard self.posts.count > 0 else {
          return
        }
        self.zoomInZoomOutAnimation(0)
      }
    }
  }
  
  private let cellId = "cellId"
  
  private var indexPathBeforeChangingOrientation: IndexPath?

  // MARK: - Lifecycle
  
  init() {
    let collectionViewLayout = CenterCellCollectionViewLayout()
    collectionViewLayout.scrollDirection = .horizontal
    
    super.init(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
    
    delegate = self
    dataSource = self
    register(ImageCell.self, forCellWithReuseIdentifier: cellId)
    
    backgroundColor = .white
    showsHorizontalScrollIndicator = false
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - MGCollectionView functions
  
  func updateData<T>(data: [T]) {
    guard let posts = data as? [Post] else {
      return
    }
    self.posts = posts
  }
  
  func prepareForOrientationChange() {
    var index = Int(floor(contentOffset.x * 3 / UIScreen.main.bounds.width))
    index = index < 0 ? 0 : index >= self.posts.count ? self.posts.count - 1 : index
    
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
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
      self.zoomInZoomOutAnimation(indexPathBeforeChangingOrientation.item)
      self.indexPathBeforeChangingOrientation = nil
    })
  }
 
  // MARK: - View Animation
  
  private func zoomInZoomOutAnimation(_ item: Int) {
    var animations: (() -> Void)?
    
    if let cell = cellForItem(at: IndexPath(item: item, section: 0)) {
      animations = {
        cell.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        self.visibleCells.filter { visibleCell in
          visibleCell != cell
          }.map {
            $0.transform = .identity
          }
      }
    } else {
      if posts.count > 0 && item < posts.count {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
          self.zoomInZoomOutAnimation(item)
        })
      }
    }
    
    if let animations = animations {
      UIView.animateKeyframes(withDuration: 0.1,
                              delay: 0,
                              options: .calculationModeCubic,
                              animations: animations,
                              completion: nil)
    }
  }
  
  // MARK: - Helper
  
  private func calculateCurrentIndex() -> Int {
    var index = Int(floor(contentOffset.x * 3 / UIScreen.main.bounds.width))
    index = index < 0 ? 0 : index >= posts.count ? posts.count - 1 : index
    return index
  }
}

// MARK: - Delegate

extension ImageCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return posts.count
  }
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ImageCell
    cell.imageUrlString = posts[indexPath.item].imageUrl
    return cell
  }
  
}

extension ImageCollectionView: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: UIScreen.main.bounds.width / 3, height: 70)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsetsMake(0, UIScreen.main.bounds.width / 3, 0, UIScreen.main.bounds.width / 3)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let index = calculateCurrentIndex()
    zoomInZoomOutAnimation(index)
    eventDelegate?.collectionView(self, didScrollTo: index)
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    eventDelegate?.collectionView(self, isScrollingTo: contentOffset.x * 3 / UIScreen.main.bounds.width)
    zoomInZoomOutAnimation(calculateCurrentIndex())
  }
}


class CenterCellCollectionViewLayout: UICollectionViewFlowLayout {
  var mostRecentOffset: CGPoint = CGPoint()
  
  override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
    if velocity.x == 0 {
      return mostRecentOffset
    }
    
    if let cv = self.collectionView {
      let cvBounds = cv.bounds
      let halfWidth = cvBounds.size.width * 0.5

      if let attributesForVisibleCells = self.layoutAttributesForElements(in: cvBounds) {
        var candidateAttributes: UICollectionViewLayoutAttributes?
        for attributes in attributesForVisibleCells {
          if (velocity.x < 0 && attributes.center.x >= cv.contentOffset.x) ||
            (velocity.x > 0 && attributes.center.x > cv.contentOffset.x + halfWidth) {
            candidateAttributes = attributes
            break
          }
        }

        guard let _ = candidateAttributes else {
          return mostRecentOffset
        }
        mostRecentOffset = CGPoint(x: floor(candidateAttributes!.center.x - halfWidth), y: proposedContentOffset.y)
        return mostRecentOffset
      }
    }

    mostRecentOffset = super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
    return mostRecentOffset
  }
}
