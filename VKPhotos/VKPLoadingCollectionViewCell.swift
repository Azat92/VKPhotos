//
//  VKPLoadingCollectionViewCell.swift
//  VKPhotos
//
//  Created by Azat Almeev on 12.09.16.
//  Copyright © 2016 Azat Almeev. All rights reserved.
//

import UIKit

class VKPLoadingCollectionViewCell: VKPReusableCollectionViewCell<NSObject> {

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        indicator.startAnimating()
    }
}
