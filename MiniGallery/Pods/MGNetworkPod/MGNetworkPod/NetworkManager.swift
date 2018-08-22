//
//  NetworkManager.swift
//  MiniGallery
//
//  Created by Jinyao Li on 8/20/18.
//  Copyright © 2018 Jinyao Li. All rights reserved.
//

import Foundation
import Disk
import AVFoundation

typealias postsHandler = (_ data: Data?, _ error: Error?) -> Void

public struct NetworkError {
  private init() {}
  
  enum Request: Error {
    case invalidParamter
    case invalidURL
    case jsonEncodingFailure
  }
  
  enum Response: Error {
    case invalidData
  }
  
  enum ParseURL: Error {
    case invalidVideoURL
  }
}

final public class NetworkManager {
  
  public static let shared = NetworkManager()
  
  init() {}
  
 func getDataFrom(urlString: String, completionHandler: @escaping postsHandler) {
    guard let url = URL(string: urlString) else {
      completionHandler(nil, NetworkError.Request.invalidURL)
      return
    }

    URLSession.shared.dataTask(with: url) { data, response, error in
      guard error == nil else {
        completionHandler(nil, NetworkError.Request.invalidURL)
        return
      }
      
      guard let data = data else {
        completionHandler(nil, NetworkError.Response.invalidData)
        return
      }
      
      completionHandler(data, error)
    }.resume()
  }
  
  public func getPostInformationFrom(urlString: String, completionHandler: (([Post]) -> Void)?) {
    var noValue = true
    do {
      let retrievedPosts = try Disk.retrieve("posts.json", from: .documents, as: [Post].self)
      completionHandler?(retrievedPosts)
      noValue = false
    } catch {
      print("Error when retrieving data: \(error.localizedDescription)")
    }
    
    getDataFrom(urlString: urlString) { data, err in
      if let data = data {
        do {
          try Disk.save(data, to: .documents, as: "posts.json")
          if noValue {
            let posts = try JSONDecoder().decode([Post].self, from: data)
            completionHandler?(posts)
          }
        } catch {
          print("There is error: \(error.localizedDescription)")
        }
      }
    }
  }
  
  public func getVideoURLFrom(_ videoUrlString: String, completionHandler: @escaping ((URL) -> Void)) {
    var noValue = true
    
    let localVideoPath = "Resource/\(videoUrlString.split(separator: "/")[3]).mp4"
    do {
      let localVideoURL = try generateLocalVideoURL(localVideoPath: localVideoPath)
      noValue = false
      completionHandler(localVideoURL)
    } catch {
      print(error.localizedDescription)
    }
    
    getDataFrom(urlString: videoUrlString) { data, err in
      guard err == nil else {
        print(err!.localizedDescription)
        return
      }
      if let data = data {
        do {
          try Disk.save(data, to: .documents, as: localVideoPath)
          if noValue {
            let localVideoURL = try self.generateLocalVideoURL(localVideoPath: localVideoPath)
            noValue = false
            completionHandler(localVideoURL)
          }
        } catch {
          print(error.localizedDescription)
        }
        
        if noValue {
          completionHandler(URL(string: videoUrlString)!)
        }
      }
    }
  }
  
  public func getUIImageFrom(_ imageUrlString: String, completionHandler: @escaping((UIImage) -> Void)) {
    var noValue = true
    let localImagePath = "Resource/\(imageUrlString.split(separator: "/")[4]).jpg"
    
    do {
      let image = try Disk.retrieve(localImagePath, from: .documents, as: UIImage.self)
      noValue = false
      completionHandler(image)
    } catch {
      print(error.localizedDescription)
    }
    
    getDataFrom(urlString: imageUrlString) { data, err in
      guard err == nil else {
        print(err!.localizedDescription)
        return
      }
      
      if let data = data, let image = UIImage(data: data) {
        do {
          try Disk.save(image, to: .documents, as: localImagePath)
        } catch {
          print(error.localizedDescription)
        }
        if noValue {
          completionHandler(image)
        }
      } else {
        print("Error generate image with data")
        if noValue {
          completionHandler(#imageLiteral(resourceName: "imageBroken"))
        }
      }
    }
  }
  
  // These lines of code are used for finding url created by Disk.
  private func generateLocalVideoURL(localVideoPath: String) throws -> URL {
    if var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
      let filePrefix = "file://"
      url.appendPathComponent(localVideoPath)
      if url.absoluteString.lowercased().prefix(filePrefix.count) != filePrefix {
        let fixedUrlString = filePrefix + url.absoluteString
        url = URL(string: fixedUrlString)!
      }
      if FileManager.default.fileExists(atPath: url.path) {
        return url
      }
    }
    
    throw NetworkError.ParseURL.invalidVideoURL
  }
}
