//
//  Post.swift
//  MiniGallery
//
//  Created by Jinyao Li on 8/18/18.
//  Copyright © 2018 Jinyao Li. All rights reserved.
//

import Foundation

public struct Post: Decodable {
  public let id: Int
  public let imageUrl: String
  public let videoUrl: String
}
