//
//  NSError+Helpers.swift
//  VKPhotos
//
//  Created by Azat Almeev on 31.07.16.
//  Copyright © 2016 Azat Almeev. All rights reserved.
//

import UIKit

extension NSError {
    
    class var unauthorized: NSError {
        return NSError(withMessage: "Seems like you are not authorized yet", andCode: 401)
    }
    
    class var unexpected: NSError {
        return NSError(withMessage: "Unexpected error")
    }
    
    convenience init(withMessage message: String) {
        self.init(withMessage: message, andCode: 1)
    }
    
    convenience init(withMessage message: String, andCode code: Int) {
        self.init(domain: "VKPhotos.Network", code: code, userInfo: [NSLocalizedDescriptionKey : message])
    }
    
    convenience init(withObject object: Any?, defaultMessage message: String, andCode code: Int) {
        let errorMessage: String = {
            guard let input = $0 as? [String : Any], let message = input["message"] as? String else { return $1 }
            return message
        }(object, message)
        self.init(domain: "VKPhotos.Network", code: code, userInfo: [NSLocalizedDescriptionKey : errorMessage])
    }
}

