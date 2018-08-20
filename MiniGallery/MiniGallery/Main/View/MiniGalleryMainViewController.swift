//
//  MiniGalleryMainViewController.swift
//  MiniGallery
//
//  Created by Jinyao Li on 8/20/18.
//  COPYRIGHT © 2018-PRESENT Jinyao Li ALL RIGHTS RESERVED.
//

import UIKit

final class MiniGalleryMainViewController: UIViewController, MiniGalleryMainView {
  

  // MARK: - Properties

  var presenter: MiniGalleryMainPresentation!
  
  var event: ExploreEvent = .none {
    didSet {
      switch event {
      case .postsDataFetched(let posts):
        videoCollectionView.updateData(data: posts)
        break
      default:
        break
      }
    }
  }
  
  // MARK: - Variables
  
  private var videoCollectionView: UICollectionView & CollectionView = VideoCollectionView()
  
  // MARK: - View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    
    presenter.getPostInformation(urlString: "http://private-04a55-videoplayer1.apiary-mock.com/pictures")
    
    [videoCollectionView].forEach {
      view.addSubview($0)
    }
    videoCollectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: UIScreen.main.bounds.width)
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)

    videoCollectionView.rescrollForOrientationChange()
  }
  
  // MARK: - Layout
  
  // MARK: - UI Interaction
  
  // MARK: - User Interaction
  
  // MARK: - Controller Logic
  
  // MARK: - Notifications
  
  // MARK: - Helpers
}
