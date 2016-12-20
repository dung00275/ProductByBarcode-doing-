//
//  Helper.swift
//  ProductByBarcode
//
//  Created by Dung Vu on 12/20/16.
//  Copyright © 2016 Zinio Pro. All rights reserved.
//

import Foundation
import UIKit

extension Bool {
    var negative: Bool {
        return !self
    }
}


func saveObjectToUserDefaults(obj: Any? , key: String) {
    let userDefults = UserDefaults.standard
    userDefults.set(obj, forKey: key)
    userDefults.synchronize()
}

func loadObjectFromUserDefaults(key: String) -> Any? {
    return UserDefaults.standard.object(forKey: key)
}

func removeObjectFromUserDefaults(key: String) {
    let userDefults = UserDefaults.standard
    userDefults.removeObject(forKey: key)
    userDefults.synchronize()
}
