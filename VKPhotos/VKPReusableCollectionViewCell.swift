//
//  VKPReusableCollectionViewCell.swift
//  VKPhotos
//
//  Created by Azat Almeev on 12.09.16.
//  Copyright © 2016 Azat Almeev. All rights reserved.
//

import UIKit

class VKPReusableCollectionViewCell<T>: UICollectionViewCell {
    
    var model: T!
    
    class var selfName: String {
        return NSStringFromClass(self).replacingOccurrences(of: "VKPhotos.", with: "")
    }
    
    class var nib: UINib {
        return UINib(nibName: selfName, bundle:nil)
    }
    
    class var cellIdentifier: String {
        return "\(selfName)Identifier"
    }
    
}
