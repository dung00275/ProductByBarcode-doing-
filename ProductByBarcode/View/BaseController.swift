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
import ALLoadingView


extension UIViewController: TrackActivityProtocol {
}


protocol DisposeableProtocol: class {
    var disposeBag: DisposeBag! { get }
    func handlerError()
}

extension DisposeableProtocol where Self: UIViewController, Self: TrackActivityProtocol {
    func setupLoading() {
        self.trackLoading.asDriver().drive(onNext: { [weak self](isLoading) in
            guard self != nil else {
                return
            }
            
            isLoading ? ALLoadingView.manager.showLoadingView(ofType: .messageWithIndicator, windowMode: .windowed) : ALLoadingView.manager.hideLoadingView()
            
        }).addDisposableTo(disposeBag)
    }
}

extension DisposeableProtocol where Self: HandlerErrorController, Self: UIViewController {
    func showErrorWith(error: Error) {
        showAlertError(message: error.localizedDescription).subscribeOn(MainScheduler.instance).bindNext {[weak self] in
            self?.handlerError()
            }.addDisposableTo(disposeBag)
    }
}


public protocol HandlerErrorController {
    func showAlertError(message: String?) -> Observable<Void>
}


public extension HandlerErrorController where Self: UIViewController {
    
    public func showAlertError(message: String?) -> Observable<Void> {
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


class BaseController: UIViewController, HandlerErrorController, DisposeableProtocol {
    
    var disposeBag: DisposeBag! = DisposeBag()
    private lazy var loadingManager = ALLoadingView.manager
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoading()
    }
    
    public func handlerError() {
        
    }
}
