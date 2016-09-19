//
//  VKPAPIWorker.swift
//  VKPhotos
//
//  Created by Azat Almeev on 12.09.16.
//  Copyright © 2016 Azat Almeev. All rights reserved.
//

import UIKit
import VKSdkFramework

extension VKUser {
    var fullName: String {
        if let firstName = first_name, let lastName = last_name, !firstName.isEmpty, !lastName.isEmpty {
            return "\(firstName) \(lastName)"
        }
        else if let firstName = first_name, !firstName.isEmpty {
            return firstName
        }
        else if let lastName = last_name, !lastName.isEmpty {
            return last_name
        }
        else {
            return first_name ?? ""
        }
    }
}

enum VKPAPIWorkerState {
    case Authorized(String?) // username
    case Error(Error) // any error
}

protocol VKPAPIWorkerDelegate: NSObjectProtocol {
    func api(worker: VKPAPIWorker, didChangeState state: VKPAPIWorkerState)
    func api(worker: VKPAPIWorker, shouldPresentController controller: UIViewController)
    func api(worker: VKPAPIWorker, didLoadPhotos photos: VKPhotoArray, withOffset offset: Int)
}

class VKPAPIWorker: NSObject, VKSdkDelegate, VKSdkUIDelegate {
    
    private let scope = ["photos"]
    weak var delegate: VKPAPIWorkerDelegate?
    
    private lazy var vkSDK: VKSdk = {
        let sdk = VKSdk.initialize(withAppId: "5626128")!
        sdk.uiDelegate = self
        VKSdk.wakeUpSession(self.scope) { [weak self] in
            guard let sender = self else { return }
            if let error = $1 {
                sender.delegate?.api(worker: sender, didChangeState: .Error(error))
            }
            else {
                switch $0 {
                case .authorized:
                    sender.delegate?.api(worker: sender, didChangeState: .Authorized(VKSdk.accessToken().localUser.fullName))
                default:
                    sender.delegate?.api(worker: sender, didChangeState: .Error(NSError.unauthorized))
                }
            }
        }
        return sdk
    }()
    
    init(withDelegate _delegate: VKPAPIWorkerDelegate) {
        super.init()
        delegate = _delegate
        vkSDK.register(self)
    }
    
    func login() {
        VKSdk.authorize(scope)
    }
    
    func logout() {
        VKSdk.forceLogout()
        delegate?.api(worker: self, didChangeState: .Error(NSError.unauthorized))
    }
    
    func loadPhotos(usingOffset offset: Int = 0) {
        guard let _ = VKSdk.accessToken() else { return }
        let request = VKApi.photos()?.prepareRequest(withMethodName: "getAll", parameters: ["extended" : 1, "offset" : offset, "count" : 100], modelClass: VKPhoto.self)
        request?.execute(resultBlock: {
            guard let json = $0?.json as? [AnyHashable : Any], let response = VKPhotoArray(dictionary: json, objectClass: VKPhoto.self) else {
                self.delegate?.api(worker: self, didChangeState: .Error(NSError.unexpected))
                return
            }
            self.delegate?.api(worker: self, didLoadPhotos: response, withOffset: offset)
        }, errorBlock: {
            guard let error = $0 else { return }
            self.delegate?.api(worker: self, didChangeState: .Error(error))
        })
    }
    
    private func handleAuthResult(result: VKAuthorizationResult!) {
        if result.state == .authorized {
            delegate?.api(worker: self, didChangeState: .Authorized(result.user.fullName))
        }
        else {
            delegate?.api(worker: self, didChangeState: .Error(NSError.unauthorized))
        }
    }
    
    //MARK: - VK SDK Delegate
    public func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        handleAuthResult(result: result)
    }
    
    func vkSdkAuthorizationStateUpdated(with result: VKAuthorizationResult!) {
        handleAuthResult(result: result)
    }

    public func vkSdkUserAuthorizationFailed() {
        delegate?.api(worker: self, didChangeState: .Error(NSError.unauthorized))
    }
    
    //MARK: - VK SDK UI Delegate
    public func vkSdkShouldPresent(_ controller: UIViewController!) {
        guard let controller = controller else { return }
        delegate?.api(worker: self, shouldPresentController: controller)
    }

    public func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
        delegate?.api(worker: self, shouldPresentController: VKCaptchaViewController.captchaControllerWithError(captchaError))
    }

}
