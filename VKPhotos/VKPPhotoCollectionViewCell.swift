//
//  VKPPhotoCollectionViewCell.swift
//  VKPhotos
//
//  Created by Azat Almeev on 12.09.16.
//  Copyright © 2016 Azat Almeev. All rights reserved.
//

import UIKit
import VKSdkFramework

class VKPPhotoCollectionViewCell: VKPReusableCollectionViewCell<VKPhoto> {

    @IBOutlet weak var photoImageView: VKPURLImage!
    
    override var model: VKPhoto! {
        didSet {
            guard let photo130 = model.photo_130, let url = URL(string: photo130) else { return }
            photoImageView.url = url
        }
    }

}
