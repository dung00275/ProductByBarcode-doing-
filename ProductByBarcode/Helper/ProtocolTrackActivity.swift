//
//  ProtocolTrackActivity.swift
//  BA3
//
//  Created by Dung Vu on 11/17/16.
//  Copyright © 2016 Zinio LLC. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa


func lockWith(object: AnyObject, closure: (Void) -> Void) {
    objc_sync_enter(object); defer { objc_sync_exit(object) }
    closure()
}

private struct TrackActivityAssociatedKeys {
    static var TrackActivityKey = "TrackActivityAssociatedKey"
}

protocol TrackActivityProtocol: class {
}

extension TrackActivityProtocol {
    public var trackLoading: ActivityIndicator {
        get {
            var trackActivity: ActivityIndicator!
            lockWith(object: self) {
                let lookup = objc_getAssociatedObject(self, &TrackActivityAssociatedKeys.TrackActivityKey) as? ActivityIndicator
                if let lookup = lookup {
                    trackActivity = lookup
                } else {
                    let newTrackLoading = ActivityIndicator()
                    self.trackLoading = newTrackLoading
                    trackActivity = newTrackLoading
                }
            }
            return trackActivity
        }
        set {
            lockWith(object: self) {
                objc_setAssociatedObject(self, &TrackActivityAssociatedKeys.TrackActivityKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}


