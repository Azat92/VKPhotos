//
//  VKPImageLoader.swift
//  VKPhotos
//
//  Created by Azat Almeev on 15.09.16.
//  Copyright © 2016 Azat Almeev. All rights reserved.
//

import UIKit
import Crypto

typealias VKPImageLoaderCompletion = (URL, UIImage?) -> Void

class VKPImageLoader: NSObject {
    
    class func loadImage(url: URL, completed: @escaping VKPImageLoaderCompletion) {
        sharedInstance.loadImage(url: url, completed: completed)
    }
    
    private override init() {
        super.init()
    }
    
    private class var sharedInstance: VKPImageLoader {
        struct Singleton {
            static let instance = VKPImageLoader()
        }
        return Singleton.instance
    }
    
    private let loadQueue = DispatchQueue(label: "VKPImageLoader.SyncQueue")
    private var loadingState: [URL : [VKPImageLoaderCompletion]] = [:]
    private lazy var operationsQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 10
        return queue
    }()
    
    private func loadImage(url: URL, completed: @escaping VKPImageLoaderCompletion) {
        cached(url: url) { (url, image) in
            if let image = image {
                DispatchQueue.main.async {
                    completed(url, image)
                }
            }
            else {
                self.loadAndCacheImage(url: url, completed: completed)
            }
        }
    }
    
    private func loadAndCacheImage(url: URL, completed: @escaping VKPImageLoaderCompletion) {
        loadQueue.sync {
            if let exists = self.loadingState[url] {
                self.loadingState[url] = exists + [completed]
                return
            }
            else {
                self.loadingState[url] = [completed]
            }
        }
        let finishWithImage: VKPImageLoaderCompletion = { (url, image) in
            var completions: [VKPImageLoaderCompletion]! = nil
            self.loadQueue.sync {
                completions = self.loadingState[url]
                self.loadingState.removeValue(forKey: url)
            }
            DispatchQueue.main.async {
                if let completions = completions {
                    for completion in completions {
                        completion(url, image)
                    }
                }
            }
        }
        operationsQueue.addOperation {
            if let imageData = try? Data(contentsOf: url), let image = UIImage(data: imageData) {
                finishWithImage(url, image)
                self.save(image: image, forURL: url)
            }
            else {
                finishWithImage(url, nil)
            }
        }
    }
    
    lazy var cachesFolder: String = {
        return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
    }()
    
    private func save(image: UIImage, forURL url: URL) {
        if let hash = url.absoluteString.md5, let data = UIImagePNGRepresentation(image) {
            let path = URL(fileURLWithPath: cachesFolder)
            try? data.write(to: path.appendingPathComponent(hash))
        }
    }
    
    private lazy var diskQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 3
        return queue
    }()
    
    private func cached(url: URL, completion: @escaping VKPImageLoaderCompletion) {
        diskQueue.addOperation {
            let path = URL(fileURLWithPath: self.cachesFolder)
            if let hash = url.absoluteString.md5, let data = try? Data(contentsOf: path.appendingPathComponent(hash)), let image = UIImage(data: data) {
                completion(url, image)
            }
            else {
                completion(url, nil)
            }
        }
    }

}
