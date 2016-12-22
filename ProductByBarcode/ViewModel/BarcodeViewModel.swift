//
//  BarcodeViewModel.swift
//  ProductByBarcode
//
//  Created by Dung Vu on 12/20/16.
//  Copyright © 2016 Zinio Pro. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxAlamofire
import Alamofire
import ObjectMapper

enum BarcodeType: Equatable {
    case none
    case createNew(product: ProductItem)
    case update(product: ProductItem)
    
    var title: String {
        switch self {
        case .createNew:
            return "Add New Product"
        case .update:
            return "Update Product"
        default:
            return ""
        }
    }
    
    var productId: Int {
        switch self {
        case .createNew(let product):
            return product.productId ?? 0
        case .update(let product):
            return product.productId ?? 0
        default:
            return 0
        }
    }
}

func ==(l: BarcodeType, r: BarcodeType) -> Bool {
    switch (l, r) {
    case (.none, .none):
        return true
    case (.createNew(let p1), .createNew(let p2)):
        return p1.productId == p2.productId
    case (.update(let p1), .update(let p2)):
       return p1.productId == p2.productId
    default:
        return false
    }
}

struct BarcodeViewModel {
    weak var controller: BaseController!
    func checkBarcode(code: String?) -> Observable<BarcodeType> {
        let router = Router.checkBarcode(code: code)
        return SessionManager.default.rx.json(router.method, router.path, parameters: router.params).map { (r) -> [CheckBarcodeItem] in
            
            guard let items = r as? [Any] else {
                throw AFError.responseValidationFailed(reason: .dataFileNil)
            }
            let mapper = Mapper<CheckBarcodeItem>()
            return items.flatMap({ mapper.map(JSONObject: $0) })
            
            }.flatMap({
                $0.count == 0 ? self.createNew(code: code) : self.updateProduct(code: code)
            }).trackActivity(controller.trackLoading)
    }
    
    func createNew(code: String?) -> Observable<BarcodeType> {
        let router = Router.createProduct(code: code)
        return SessionManager.default.rx.json(router.method, router.path, parameters: router.params).map { (r) -> BarcodeType in
            guard let response = Mapper<ProductItem>().map(JSONObject: r) else {
                throw AFError.responseValidationFailed(reason: .dataFileNil)
            }
            
            return BarcodeType.createNew(product: response)
        }
    }
    
    func updateProduct(code: String?) -> Observable<BarcodeType> {
        let router = Router.updateProduct(code: code)
        
        return SessionManager.default.rx.json(router.method, router.path, parameters: router.params).map { (r) -> BarcodeType in
            guard let response = Mapper<ProductItem>().map(JSONObject: r) else {
                throw AFError.responseValidationFailed(reason: .dataFileNil)
            }
            
            return BarcodeType.update(product: response)
        }
    }
    
}
