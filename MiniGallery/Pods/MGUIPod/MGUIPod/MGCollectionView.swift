//
//  MGCollectionView.swift
//  PinOn
//
//  Created by Jinyao Li on 8/20/18.
//  Copyright (c) 2017-present, PinOn, Inc. All rights reserved.
//

import UIKit

public protocol MGCollectionView {
  var eventDelegate: MGCollectionViewDelegate? { get set }
  func updateData<T>(data: [T])
  func prepareForOrientationChange()
  func rescrollForOrientationChange()
}

public protocol MGCollectionViewDelegate: class {
  func collectionView(_ view: UICollectionView & MGCollectionView, didScrollTo index: Int)
  func collectionView(_ view: UICollectionView & MGCollectionView, isScrollingTo index: CGFloat)
}
