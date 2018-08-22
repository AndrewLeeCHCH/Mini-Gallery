//
//  ImageCell.swift
//  PinOn
//
//  Created by Jinyao Li on 8/20/18.
//  Copyright (c) 2017-present, PinOn, Inc. All rights reserved.
//

import UIKit

final internal class ImageCell: UICollectionViewCell {
  
  // MARK: - Variables
  
  internal var image: UIImage? {
    didSet {
      DispatchQueue.main.async {
        self.imageView.image = self.image
      }
    }
  }
  
  internal var imageUrlString: String? {
    didSet {
      if let imageUrlString = imageUrlString, let imageUrl = URL(string: imageUrlString) {
        URLSession.shared.dataTask(with: imageUrl) { data, response, error in
          if let data = data, let image = UIImage(data: data) {
            DispatchQueue.main.async {
              self.imageView.image = image
            }
          }
        }.resume()
      }
    }
  }
  
  // MARK: - View Components
  
  internal let imageView = UIImageView()

  // MARK: - Lifecycle
  
  override internal init(frame: CGRect) {
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
