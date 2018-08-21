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
        imageCollectionView.updateData(data: posts)
        break
      default:
        break
      }
    }
  }
  
  // MARK: - Variables
  
  private var videoCollectionView: UICollectionView & MGCollectionView = VideoCollectionView()
  private var imageCollectionView: UICollectionView & MGCollectionView = ImageCollectionView()
  
  // MARK: - Lifecyle
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    
    presenter.getPostInformation(urlString: "http://private-04a55-videoplayer1.apiary-mock.com/pictures")
    
    [videoCollectionView, imageCollectionView].forEach {
      view.addSubview($0)
    }
    videoCollectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: UIScreen.main.bounds.width)
    imageCollectionView.anchor(top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 120)
    
    imageCollectionView.eventDelegate = self
    videoCollectionView.eventDelegate = self
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(didReceiveOrientationChangeNotification),
                                           name: .UIDeviceOrientationDidChange,
                                           object: nil)
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    
    videoCollectionView.prepareForOrientationChange()
    imageCollectionView.prepareForOrientationChange()
  }

  // MARK: - Notifications
  
  @objc private func didReceiveOrientationChangeNotification(_ notification: Notification) {
    if UIDevice.current.orientation.isLandscape || UIDevice.current.orientation.isPortrait {
      videoCollectionView.rescrollForOrientationChange()
      imageCollectionView.rescrollForOrientationChange()
    }
  }
  
  // MARK: - Helpers
}

extension MiniGalleryMainViewController: MGCollectionViewDelegate {
  func collectionView(_ view: UICollectionView & MGCollectionView, didScrollTo index: Int) {
    if view == imageCollectionView {
      videoCollectionView.scrollToItem(at: IndexPath(item: index, section: 0),
                                       at: .centeredHorizontally,
                                       animated: true)
    } else if view == videoCollectionView {
      imageCollectionView.scrollToItem(at: IndexPath(item: index, section: 0),
                                       at: .centeredHorizontally,
                                       animated: true)
    }
  }
  
  func collectionView(_ view: UICollectionView & MGCollectionView, isScrollingTo index: CGFloat) {

  }
}
