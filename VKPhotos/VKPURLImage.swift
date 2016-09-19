//
//  VKPURLImage.swift
//  VKPhotos
//
//  Created by Azat Almeev on 15.09.16.
//  Copyright © 2016 Azat Almeev. All rights reserved.
//

import UIKit

class VKPURLImage: UIImageView {

    private let indicatorViewTag = 1
    
    var url: URL! {
        didSet {
            self.image = nil
            if let url = url {
                let indicator = viewWithTag(indicatorViewTag) as? UIActivityIndicatorView ?? UIActivityIndicatorView(activityIndicatorStyle: .gray)
                indicator.startAnimating()
                indicator.tag = indicatorViewTag
                indicator.center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
                indicator.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleTopMargin]
                addSubview(indicator)
                VKPImageLoader.loadImage(url: url) { [weak self] in
                    if let currentURL = self?.url, $0 == currentURL {
                        self?.image = $1
                        indicator.removeFromSuperview()
                    }
                }
            }
        }
    }

}
