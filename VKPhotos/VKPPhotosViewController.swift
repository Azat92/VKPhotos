//
//  ViewController.swift
//  VKPhotos
//
//  Created by Azat Almeev on 12.09.16.
//  Copyright © 2016 Azat Almeev. All rights reserved.
//

import UIKit
import VKSdkFramework

class VKPPhotosViewController: UICollectionViewController {
    
    fileprivate var allPhotos: [VKPhoto] = []
    fileprivate var haveLoadingIndicator = false
    fileprivate var haveRequestForAppend = false {
        didSet {
            navigationItem.rightBarButtonItem?.isEnabled = !haveRequestForAppend
        }
    }
    
    fileprivate lazy var backView: VKPLoadingView = {
        let view = VKPLoadingView.viewFromXib()
        view.delegate = self
        return view
    }()
    
    fileprivate lazy var apiWorker: VKPAPIWorker = {
        return VKPAPIWorker(withDelegate: self)
    }()
    
    fileprivate lazy var pullToRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlDidFire(sender:)), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        collectionView?.backgroundView = backView
        collectionView?.register(VKPPhotoCollectionViewCell.nib, forCellWithReuseIdentifier: VKPPhotoCollectionViewCell.cellIdentifier)
        collectionView?.register(VKPLoadingCollectionViewCell.nib, forCellWithReuseIdentifier: VKPLoadingCollectionViewCell.cellIdentifier)
        apiWorker.loadPhotos()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPhotoSegue", let dvc = segue.destination as? VKPPhotoDetailViewController, let index = sender as? IndexPath {
            dvc.photos = allPhotos
            dvc.index = index.item
        }
    }
    
    @IBAction func refreshControlDidFire(sender: UIRefreshControl) {
        guard !self.haveRequestForAppend else {
            sender.endRefreshing()
            return
        }
        allPhotos = []
        haveLoadingIndicator = false
        collectionView?.reloadData()
        apiWorker.loadPhotos()
    }
    
    @IBAction func signOutButtonDidClick(sender: UIBarButtonItem) {
        guard !self.haveRequestForAppend else { return }
        let alert = UIAlertController(title: "Sign Out", message: "Please confirm action", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Confirm", style: .destructive) { _ in
            self.apiWorker.logout()
        })
        present(alert, animated: true, completion: nil)
    }
}

extension VKPPhotosViewController { // Collection View Data Source & Delegate
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPhotos.count + (haveLoadingIndicator ? 1 : 0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item < allPhotos.count, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VKPPhotoCollectionViewCell.cellIdentifier, for: indexPath) as? VKPPhotoCollectionViewCell {
            cell.model = allPhotos[indexPath.item]
            return cell
        }
        else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: VKPLoadingCollectionViewCell.cellIdentifier, for: indexPath)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == allPhotos.count, !haveRequestForAppend {
            haveRequestForAppend = true
            apiWorker.loadPhotos(usingOffset: allPhotos.count)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowPhotoSegue", sender: indexPath)
    }
}

extension VKPPhotosViewController: VKPAPIWorkerDelegate { // API Worker Delegate
    
    private var defaultTitle: String { return "VK Photos" }
    
    func api(worker: VKPAPIWorker, shouldPresentController controller: UIViewController) {
        self.present(controller, animated: true, completion: nil)
    }
    
    func api(worker: VKPAPIWorker, didChangeState state: VKPAPIWorkerState) {
        switch state {
        case .Authorized(let user):
            title = user ?? defaultTitle
            backView.mode = .Loading
            apiWorker.loadPhotos()
            collectionView?.refreshControl = pullToRefreshControl
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .done, target: self, action: #selector(signOutButtonDidClick(sender:)))
        case .Error(let error):
            backView.mode = .Error(error)
            title = defaultTitle
            allPhotos = []
            haveLoadingIndicator = false
            collectionView?.reloadSections(IndexSet(integer: 0))
            collectionView?.refreshControl = nil
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    func api(worker: VKPAPIWorker, didLoadPhotos photos: VKPhotoArray, withOffset offset: Int) {
        pullToRefreshControl.endRefreshing()
        if photos.count > 0, let items = photos.items, let newPhotos = Array(items) as? [VKPhoto] {
            backView.mode = .Data
            let indices = (allPhotos.count ..< allPhotos.count + newPhotos.count).map {
                IndexPath(item: $0, section: 0)
            }
            allPhotos = allPhotos + newPhotos
            let oldValueForLoadingIndicator = haveLoadingIndicator
            haveLoadingIndicator = allPhotos.count < Int(photos.count)
            collectionView?.performBatchUpdates({
                self.collectionView?.insertItems(at: indices)
                if !oldValueForLoadingIndicator && self.haveLoadingIndicator {
                    self.collectionView?.insertItems(at: [IndexPath(item: self.allPhotos.count, section: 0)])
                }
                else if oldValueForLoadingIndicator && !self.haveLoadingIndicator {
                    self.collectionView?.deleteItems(at: [IndexPath(item: self.allPhotos.count - newPhotos.count, section: 0)])
                }
            }) { _ in self.haveRequestForAppend = false }
        }
        else {
            backView.mode = .Error(NSError(withMessage: "Seems like you have no photos"))
        }
    }
}

extension VKPPhotosViewController: VKPLoadingViewDelegate { // Loading View Delegate
    
    func loadingViewDidClickAuthButton(sender: VKPLoadingView) {
        apiWorker.login()
    }
    
    func loadingViewDidClickRetryButton(sender: VKPLoadingView) {
        apiWorker.loadPhotos()
    }
}
