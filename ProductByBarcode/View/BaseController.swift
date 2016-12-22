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
    var loadingManager: ALLoadingView { get }
    func handlerError()
}

extension DisposeableProtocol where Self: UIViewController, Self: TrackActivityProtocol {
    func setupLoading() {
        self.trackLoading.skip(1).asDriver().drive(onNext: { [weak self](isLoading) in
            guard let weakSelf = self else {
                return
            }
            
            isLoading ? weakSelf.loadingManager.showLoadingView(ofType: .messageWithIndicator, windowMode: .windowed) : weakSelf.loadingManager.hideLoadingView()
            
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
    func showAlertError(t: String?, message: String?) -> Observable<Void>
}


public extension HandlerErrorController where Self: UIViewController {
    
    public func showAlertError(t: String? = "Error", message: String?) -> Observable<Void> {
        return Observable.create({ [unowned self](r) -> Disposable in
            let actionOk = UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
                r.onNext()
                r.onCompleted()
            })
            
            let alertController = UIAlertController(title: t, message: message, preferredStyle: .alert)
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
    lazy var loadingManager = ALLoadingView.manager
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoading()
    }
    
    public func handlerError() {
        
    }
}
