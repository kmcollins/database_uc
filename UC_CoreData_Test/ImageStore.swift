//
//  ImageStore.swift
//  UC_CoreData_Test
//
//  Created by Katie Collins on 2/10/17.
//  Copyright © 2017 CollinsInnovation. All rights reserved.
//

import UIKit

class ImageStore {

    let cache = NSCache<NSString, UIImage>()
    
    func setImage(image: UIImage, forKey key: String) {
        print("setting image for key \(key)")
        cache.setObject(image, forKey: key as NSString)
    }
    
    func imageForKey(key: String) -> UIImage? {
        print(cache)
        print("image for key")
        print("key: \(key)")
        return cache.object(forKey: key as NSString)
    }
    
    func deleteImageForKey(key: String) {
        cache.removeObject(forKey: key as NSString)
    }
 
    /*
    var images = Dictionary<String, UIImage>()
    
    func setImage(image: UIImage, forKey key: String) {
        images[key] = image
    }
    
    func imageForKey(key: String) -> UIImage? {
        return images[key]
    }
    
    func deleteImageForKey(key: String) {
        images.removeValue(forKey: key)
    }*/
}
