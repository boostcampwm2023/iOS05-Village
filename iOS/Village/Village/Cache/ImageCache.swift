//
//  ImageCache.swift
//  Village
//
//  Created by 박동재 on 12/13/23.
//

import UIKit

final class ImageCache {
    
    static let shared = ImageCache()
    private let cache = NSCache<NSURL, NSData>()
    
    private init() {
          cache.totalCostLimit = 100
      }
    
    func getImageData(for key: NSURL) -> NSData? {
        if let cachedImageData = cache.object(forKey: key as NSURL) {
            return cachedImageData
        }
        
        return nil
    }
    
    func setImageData(_ data: NSData, for key: NSURL) {
        cache.setObject(data, forKey: key as NSURL)
    }

}
