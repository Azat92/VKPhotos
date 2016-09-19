//
//  Array+Helpers.swift
//  VKPhotos
//
//  Created by Azat Almeev on 15.09.16.
//  Copyright © 2016 Azat Almeev. All rights reserved.
//

import UIKit

func +<T>(left: Array<T>, right: Array<T>) -> Array<T> {
    var acc = left
    acc.append(contentsOf: right)
    return Array(acc)
}
