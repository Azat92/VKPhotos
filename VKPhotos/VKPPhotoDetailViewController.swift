//
//  VKPPhotoDetailViewController.swift
//  VKPhotos
//
//  Created by Azat Almeev on 16.09.16.
//  Copyright © 2016 Azat Almeev. All rights reserved.
//

import UIKit
import VKSdkFramework

class VKPPhotoDetailViewController: UIViewController {

    var photos: [VKPhoto]!
    var index: Int!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EmbedPageControllerSegue", let dvc = segue.destination as? VKPPhotoScrollViewController {
            dvc.photos = photos
            dvc.index = index
            dvc.navigation = navigationItem
        }
    }
}
