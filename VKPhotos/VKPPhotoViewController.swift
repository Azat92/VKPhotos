//
//  VKPImageViewController.swift
//  VKPhotos
//
//  Created by Azat Almeev on 16.09.16.
//  Copyright © 2016 Azat Almeev. All rights reserved.
//

import UIKit
import VKSdkFramework

class VKPPhotoViewController: UIViewController {

    var photo: VKPhoto!
    var index: Int!
    weak var navigation: UINavigationItem?
    
    @IBOutlet weak var imageView: VKPURLImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let photo = photo.photo_2560, let url = URL(string: photo) {
            imageView.url = url
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let likes = photo.fields["likes"] as? [AnyHashable : Any], let count = likes["count"] {
            navigation?.title = "Likes: \(count)"
        }
        else {
            navigation?.title = "Likes: 0"
        }
    }
}
