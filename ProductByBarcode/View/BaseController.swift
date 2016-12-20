//
//  BaseController.swift
//  ProductByBarcode
//
//  Created by Dung Vu on 12/20/16.
//  Copyright © 2016 Zinio Pro. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class BaseController: UIViewController {
    func showAlertError(message: String?) -> Observable<Void> {
        return Observable.create({ [unowned self](r) -> Disposable in
            let actionOk = UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
                r.onNext()
                r.onCompleted()
            })
            
            let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alertController.addAction(actionOk)
            
            
            self.present(alertController, animated: true, completion: nil)
            
            return Disposables.create {
                alertController.dismiss(animated: true, completion: nil)
            }
        })
    }
    
}
