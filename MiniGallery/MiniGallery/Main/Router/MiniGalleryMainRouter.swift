//
//  MiniGalleryMainRouter.swift
//  MiniGallery
//
//  Created by Jinyao Li on 8/20/18.
//  COPYRIGHT © 2018-PRESENT Jinyao Li ALL RIGHTS RESERVED.
//

import UIKit

func makeMiniGalleryMainModule() -> UIViewController {
  let view = MiniGalleryMainViewController()
  let interactor = MiniGalleryMainInteractor()
  let presenter = MiniGalleryMainPresenter()
  
  view.presenter = presenter
  
  interactor.output = presenter
  
  presenter.view = view
  presenter.interactor = interactor
  
  return view
}
