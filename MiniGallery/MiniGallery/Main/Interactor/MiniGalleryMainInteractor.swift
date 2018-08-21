//
//  MiniGalleryMainInteractor.swift
//  MiniGallery
//
//  Created by Jinyao Li on 8/20/18.
//  COPYRIGHT © 2018-PRESENT Jinyao Li ALL RIGHTS RESERVED.
//

final class MiniGalleryMainInteractor {

  weak var output: MiniGalleryMainInteractorOutput?
}

extension MiniGalleryMainInteractor: MiniGalleryMainUseCase {
  func requestForPostInformation(urlString: String) {
    NetworkManager.shared.getPostInformationFrom(urlString: urlString) { posts in
      self.output?.didReceivePostInformation(posts: posts)
    }
  }
}
