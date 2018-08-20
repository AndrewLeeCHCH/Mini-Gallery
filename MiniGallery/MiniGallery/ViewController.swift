//
//  ViewController.swift
//  MiniGallery
//
//  Created by Jinyao Li on 8/18/18.
//  Copyright © 2018 Jinyao Li. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  private var videoCollectionView = VideoCollectionView()

  private var imageCollectionView = ImageCollectionView()
  
  private let imageCellId = "imageCellId"
  private let videoCellId = "videoCellId"
  
  private var posts: [Post] = [] {
    didSet {
      DispatchQueue.main.async {
        self.imageCollectionView.posts = self.posts
        self.videoCollectionView.posts = self.posts
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    [videoCollectionView, imageCollectionView].forEach {
      view.addSubview($0)
    }
    videoCollectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: UIScreen.main.bounds.width)
    videoCollectionView.backgroundColor = .red
    
    imageCollectionView.anchor(top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 120)
    imageCollectionView.backgroundColor = .blue
    
    imageCollectionView.eventDelegate = self
    videoCollectionView.eventDelegate = self
//    imageCollectionView.delegate = self
//    imageCollectionView.dataSource = self
//    videoCollectionView.delegate = self
//    videoCollectionView.dataSource = self
    
    
//    imageCollectionView.register(ImageCell.self, forCellWithReuseIdentifier: imageCellId)
//    videoCollectionView.register(VideoCell.self, forCellWithReuseIdentifier: videoCellId)
    
    let url = URL(string: "http://private-04a55-videoplayer1.apiary-mock.com/pictures")
    URLSession.shared.dataTask(with: url!) { (data, response, err) in
      guard let data = data else {
        return
      }
      
      do {
        let posts = try JSONDecoder().decode([Post].self, from: data)
        self.posts = posts
      } catch let jsonErr {
        print(jsonErr)
      }
      }.resume()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    
    if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
      
    } else {
      
    }
  }

}

extension ViewController: ImageCollectionViewDelegate {
  func imageDidScrollTo(index: Int) {
//    videoCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .left, animated: true)
  }
}

extension ViewController: VideoCollectionViewDelegate {
  func didScrollTo(index: Int) {
//    imageCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
  }
}
