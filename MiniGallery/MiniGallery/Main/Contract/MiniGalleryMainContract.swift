//
//  MiniGalleryMainContract.swift
//  MiniGallery
//
//  Created by Jinyao Li on 8/20/18.
//  COPYRIGHT © 2018-PRESENT Jinyao Li ALL RIGHTS RESERVED.
//

enum ExploreEvent {
  case none
  case postsDataFetched(posts: [Post])
}

protocol MiniGalleryMainView: class { // View
  var presenter: MiniGalleryMainPresentation! { get set }
  
  var event: ExploreEvent { get set }
}

protocol MiniGalleryMainUseCase: class { // Interactor
  var output: MiniGalleryMainInteractorOutput? { get set }
  
  func requestForPostInformation(urlString: String)
}

protocol MiniGalleryMainPresentation: class { // Presenter
  var view: MiniGalleryMainView? { get set }
  var interactor: MiniGalleryMainUseCase! { get set }
  
  func getPostInformation(urlString: String)
}

protocol MiniGalleryMainInteractorOutput: class { // Presenter
  func didReceivePostInformation(posts: [Post])
}

