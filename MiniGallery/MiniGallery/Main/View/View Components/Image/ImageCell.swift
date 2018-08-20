//
//  ImageCell.swift
//  PinOn
//
//  Created by Jinyao Li on 8/20/18.
//  Copyright (c) 2017-present, PinOn, Inc. All rights reserved.
//

import UIKit

final class ImageCell: UICollectionViewCell {

  // MARK: - Constants
  
  // MARK: - Variables
  
  var imageUrlString: String = "" {
    didSet {
      NetworkManager.shared.getUIImageFrom(imageUrlString) { image in
        DispatchQueue.main.async {
          self.imageView.image = image
        }
      }
    }
  }
  
  let imageView = UIImageView()
  
  // MARK: - View Components

  // MARK: - Lifecycle
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    [imageView].forEach {
      addSubview($0)
    }
    
    imageView.anchor(centerX: centerXAnchor, centerY: centerYAnchor, width: 60, height: 60)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View Lifecycle

  // MARK: - View Value Assignments
  
  // MARK: - Layout

  // MARK: - UI Interaction

  // MARK: - User Interaction

  // MARK: - Controller Logic

  // MARK: - Listeners

  // MARK: - Helpers

}

// MARK: - Delegate
