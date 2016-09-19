//
//  VKPPhotoScrollViewController.swift
//  VKPhotos
//
//  Created by Azat Almeev on 16.09.16.
//  Copyright © 2016 Azat Almeev. All rights reserved.
//

import UIKit
import VKSdkFramework

class VKPPhotoScrollViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    var photos: [VKPhoto]!
    var index: Int!
    weak var navigation: UINavigationItem?

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let prev = viewController as? VKPPhotoViewController, prev.index + 1 < photos.count, let dvc = photoController(withPhoto: photos[prev.index + 1], index: prev.index + 1) else { return nil }
        return dvc
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let prev = viewController as? VKPPhotoViewController, prev.index > 0, let dvc = photoController(withPhoto: photos[prev.index - 1], index: prev.index - 1) else { return nil }
        return dvc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        guard let dvc = photoController(withPhoto: photos[index], index: index) else { return }
        setViewControllers([dvc], direction: .forward, animated: false, completion: nil)
        delegate = self
        dataSource = self
    }
    
    private func photoController(withPhoto photo: VKPhoto, index: Int) -> VKPPhotoViewController? {
        guard let dvc = storyboard?.instantiateViewController(withIdentifier: "PhotoVC") as? VKPPhotoViewController else { return nil }
        dvc.photo = photo
        dvc.index = index
        dvc.navigation = navigation
        return dvc
    }
}
