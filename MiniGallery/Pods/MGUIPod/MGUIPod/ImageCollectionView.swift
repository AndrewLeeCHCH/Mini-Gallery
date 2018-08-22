//
//  ImageCollectionView.swift
//  PinOn
//
//  Created by Jinyao Li on 8/20/18.
//  Copyright (c) 2017-present, PinOn, Inc. All rights reserved.
//

import UIKit

final public class ImageCollectionView: UICollectionView, MGCollectionView {
  
  // MARK: - Variables
  
  weak public var eventDelegate: MGCollectionViewDelegate?
  
  internal var images: [Any] = [] {
    didSet {
      DispatchQueue.main.async {
        self.reloadData()
        guard self.images.count > 0 else {
          return
        }
        self.zoomInZoomOutAnimation(0)
      }
    }
  }
  
  internal let cellId = "cellId"
  
  internal var indexPathBeforeChangingOrientation: IndexPath?

  // MARK: - Lifecycle
  
  public init() {
    let collectionViewLayout = CenterCellCollectionViewLayout()
    collectionViewLayout.scrollDirection = .horizontal
    
    super.init(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
    
    delegate = self
    dataSource = self
    register(ImageCell.self, forCellWithReuseIdentifier: cellId)
    
    backgroundColor = .white
    showsHorizontalScrollIndicator = false
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - MGCollectionView functions
  
  public func updateData<T>(data: [T]) {
    self.images = data
  }
  
  public func prepareForOrientationChange() {
    var index = Int(floor(contentOffset.x * 3 / UIScreen.main.bounds.width))
    index = index < 0 ? 0 : index >= self.images.count ? self.images.count - 1 : index
    
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
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
      self.zoomInZoomOutAnimation(indexPathBeforeChangingOrientation.item)
      self.indexPathBeforeChangingOrientation = nil
    })
  }
 
  // MARK: - View Animation
  
  internal func zoomInZoomOutAnimation(_ item: Int) {
    var animations: (() -> Void)?
    
    if let cell = cellForItem(at: IndexPath(item: item, section: 0)) {
      animations = {
        cell.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        _ = self.visibleCells.filter { visibleCell in
          visibleCell != cell
          }.map {
            $0.transform = .identity
          }
      }
    } else {
      if images.count > 0 && item < images.count {
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
  
  internal func calculateCurrentIndex() -> Int {
    var index = Int(floor(contentOffset.x * 3 / UIScreen.main.bounds.width))
    index = index < 0 ? 0 : index >= images.count ? images.count - 1 : index
    return index
  }
}

// MARK: - Delegate

extension ImageCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return images.count
  }
  
  public func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ImageCell
    if let image = images[indexPath.item] as? UIImage {
      cell.image = image
    } else if let imageUrlString = images[indexPath.item] as? String {
      cell.imageUrlString = imageUrlString
    }
    return cell
  }
  
}

extension ImageCollectionView: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: UIScreen.main.bounds.width / 3, height: 70)
  }
  
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsetsMake(0, UIScreen.main.bounds.width / 3, 0, UIScreen.main.bounds.width / 3)
  }
  
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  
  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let index = calculateCurrentIndex()
    zoomInZoomOutAnimation(index)
    eventDelegate?.collectionView(self, didScrollTo: index)
  }
  
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
