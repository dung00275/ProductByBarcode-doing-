//
//  AppDelegate.swift
//  ProductByBarcode
//
//  Created by Dung Vu on 12/20/16.
//  Copyright © 2016 Zinio Pro. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxAlamofire
import ObjectMapper
import Alamofire

let kAllTypes = "kAllTypes"
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var dispose: Disposable?
    fileprivate var isNeedSave: Bool = false
    fileprivate (set) var quantityTypes: [QuantityTypeItem] = [] {
        didSet{
            guard isNeedSave else {
                return
            }
            let data = NSKeyedArchiver.archivedData(withRootObject: quantityTypes)
            saveObjectToUserDefaults(obj: data, key: kAllTypes)
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Get quantityTypes
        dispose = checkQuantityTypes().subscribe(onNext: { [weak self](items) in
            self?.isNeedSave = true
            self?.quantityTypes = items
            self?.dispose?.dispose()
        }, onError: { [weak self](err) in
            print(err)
            // Load cache
            defer {
                self?.dispose?.dispose()
            }
            guard let localSave = loadObjectFromUserDefaults(key: kAllTypes) as? Data, let items = NSKeyedUnarchiver.unarchiveObject(with: localSave) as? [QuantityTypeItem], items.count > 0 else {
                return
            }
            self?.isNeedSave = false
            self?.quantityTypes = items
            self?.dispose?.dispose()
            },onDisposed: { [weak self]_ in
                self?.isNeedSave = false
        })
        return true
    }
}

// MARK: Get quantity type first
extension AppDelegate {
    func checkQuantityTypes() -> Observable<[QuantityTypeItem]> {
        let router = Router.getQuantityTypes
        
        return SessionManager.default.rx.json(router.method, router.path).map { (r) -> [QuantityTypeItem] in
            guard let items = r as? [Any] else {
                throw AFError.responseValidationFailed(reason: .dataFileNil)
            }
            let mapper = Mapper<QuantityTypeItem>()
            return items.flatMap({ mapper.map(JSONObject: $0)})
        }
    }
}

