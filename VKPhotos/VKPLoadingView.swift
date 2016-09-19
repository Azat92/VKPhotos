//
//  VKPLoadingView.swift
//  VKPhotos
//
//  Created by Azat Almeev on 23.08.16.
//  Copyright © 2016 Azat Almeev. All rights reserved.
//

import UIKit

enum VKPLoadingViewMode {
    case Loading
    case Error(Error)
    case Data
}

protocol VKPLoadingViewDelegate: NSObjectProtocol {
    func loadingViewDidClickAuthButton(sender: VKPLoadingView)
    func loadingViewDidClickRetryButton(sender: VKPLoadingView)
}

class VKPLoadingView: UIView {

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    
    weak var delegate: VKPLoadingViewDelegate?
    
    class func viewFromXib() -> VKPLoadingView {
        return UINib(nibName: "VKPLoadingView", bundle: nil).instantiate(withOwner: self, options: nil).first as! VKPLoadingView
    }

    var mode: VKPLoadingViewMode = .Loading {
        didSet {
            switch mode {
            case .Loading:
                indicator.startAnimating()
                statusLabel.text = "Loading..."
                retryButton.isHidden = true
            case .Error(let error):
                indicator.stopAnimating()
                statusLabel.text = error.localizedDescription
                retryButton.isHidden = false
                if (error as NSError).code == 401 {
                    retryButton.setTitle("Sign In", for: .normal)
                }
                else {
                    retryButton.setTitle("Retry", for: .normal)
                }
            case .Data:
                indicator.stopAnimating()
                statusLabel.text = nil
                retryButton.isHidden = true
            }
        }
    }
    
    @IBAction func retryButtonDidClick(sender: UIButton) {
        if case .Error(let error) = mode, (error as NSError).code == 401 {
            delegate?.loadingViewDidClickAuthButton(sender: self)
        }
        else {
            mode = .Loading
            delegate?.loadingViewDidClickRetryButton(sender: self)
        }
    }
    
}
