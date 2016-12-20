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

struct BarcodeViewModel {
    func checkBarcode(code: String?) -> Observable<[CheckBarcodeItem]> {
        let router = Router.checkBarcode(code: code)
        return SessionManager.default.rx.json(router.method, router.path, parameters: router.params).map { (r) -> [CheckBarcodeItem] in
            
            guard let items = r as? [Any] else {
                throw AFError.responseValidationFailed(reason: .dataFileNil)
            }
            let mapper = Mapper<CheckBarcodeItem>()
            return items.flatMap({ mapper.map(JSONObject: $0) })
            
        }.catchErrorJustReturn([])
    }
    
}
