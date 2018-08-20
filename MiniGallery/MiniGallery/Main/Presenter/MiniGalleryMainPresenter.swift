//
//  MiniGalleryMainPresenter.swift
//  MiniGallery
//
//  Created by Jinyao Li on 8/20/18.
//  COPYRIGHT © 2018-PRESENT Jinyao Li ALL RIGHTS RESERVED.
//

final class MiniGalleryMainPresenter {

  // MARK: - Properties

  weak var view: MiniGalleryMainView?
  var interactor: MiniGalleryMainUseCase!

  // MARK: - Lifecycle

}

extension MiniGalleryMainPresenter: MiniGalleryMainPresentation {
  func getPostInformation(urlString: String) {
    interactor.requestForPostInformation(urlString: urlString)
  }
}

extension MiniGalleryMainPresenter: MiniGalleryMainInteractorOutput {
  func didReceivePostInformation(posts: [Post]) {
    view?.event = .postsDataFetched(posts: posts)
  }
}