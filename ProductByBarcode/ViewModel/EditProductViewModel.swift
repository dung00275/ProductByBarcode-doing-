//
//  EditProductViewModel.swift
//  ProductByBarcode
//
//  Created by Dung Vu on 12/22/16.
//  Copyright © 2016 Zinio Pro. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxAlamofire
import Alamofire

enum ImageUploadError: Error {
    case noFile
    case noResponse
}
struct EditProductViewModel {
    
    func uploadImages(images: [ImagesInfo], with productId: String) -> Observable<[String]>{
        let allRequest = images.flatMap({ self.uploadImage(image: $0, with: productId) })
        return Observable.zip(allRequest) {
            return $0
        }
    }
    
    func uploadImage(image: ImagesInfo, with productId: String) -> Observable<String> {
        guard let url = image.path else {
            return Observable.error(ImageUploadError.noFile)
        }
        
        let fileName = url.lastPathComponent
        let router = Router.uploadImage(fileName: fileName, productId: productId)
        
        return Observable.create({ (o) -> Disposable in
            SessionManager.default.upload(multipartFormData: { (multiparForm) in
                multiparForm.append(url, withName: "file")
                multiparForm.append(fileName.data(using: .utf8, allowLossyConversion: false)!, withName: "fileName")
                multiparForm.append(productId.data(using: .utf8, allowLossyConversion: false)!, withName: "productId")
            }, to: router.path) { (res) in
                switch res {
                case .success(let request , _, _):
                    print("abc")
                    request.response(completionHandler: { (r) in
                        guard let d = r.data, let str = String.init(data: d, encoding: .utf8) else {
                            o.onError(ImageUploadError.noResponse)
                            return
                        }
                        try? FileManager.default.removeItem(at: url)
                        o.onNext(str)
                        o.onCompleted()
                    
                    })
                case .failure(let err):
                    o.onError(err)
                }
            }
            return Disposables.create()
        })
    }
    
    
    
    func saveProduct(p: ProductInfo) -> Observable<Void> {
        let router = Router.saveProduct(product: p)
        return SessionManager.default.rx.json(router.method, router.path, parameters: router.params).map { (r) -> () in
            print("result : \(r)!!!!!!")
        }
    }
}
