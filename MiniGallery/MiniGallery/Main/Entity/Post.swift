//
//  Post.swift
//  MiniGallery
//
//  Created by Jinyao Li on 8/18/18.
//  Copyright © 2018 Jinyao Li. All rights reserved.
//

import Foundation

struct Post: Decodable {
  let id: Int
  let imageUrl: String
  let videoUrl: String
}
