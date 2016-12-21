//
//  PickerTypeViewController.swift
//  ProductByBarcode
//
//  Created by Dung Vu on 12/21/16.
//  Copyright © 2016 Zinio Pro. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class PickerTypeViewController: UIViewController {
    let disposeBag: DisposeBag = DisposeBag()
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    
    let subjectChooseItem: PublishSubject<QuantityTypeItem?> = PublishSubject()
    var diposeDone: Disposable?
    var currentItem: QuantityTypeItem?
    
    override func viewDidLoad() {
        containerView.transform = CGAffineTransform(translationX: 0, y: 1000)
        btnCancel.rx.tap.asObservable().flatMap({ [unowned self]_ in
            return self.showPicker(isShow: false)
        }).bindNext { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }.addDisposableTo(disposeBag)
        
        diposeDone = btnDone.rx.tap.asObservable().flatMap({ [unowned self]_ in
            return self.showPicker(isShow: false)
        }).subscribe(onNext: { [weak self](_) in
            let item = self?.currentItem
            self?.subjectChooseItem.onNext(item)
            self?.diposeDone?.dispose()
            }, onDisposed: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setCurrentIndex()
        showPicker().bindNext {
            print("Show")
        }.addDisposableTo(disposeBag)
    }
    
    func setCurrentIndex() {
        guard let currentItem = currentItem, let i = appDelegate.quantityTypes.index(of: currentItem) else {
            return
        }
        
        self.pickerView.selectRow(i, inComponent: 0, animated: true)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func showPicker(isShow: Bool = true) -> Observable<Void> {
        return Observable.create({ (r) -> Disposable in
            UIView.animate(withDuration: 0.3, animations: {
                self.containerView.transform = isShow ? CGAffineTransform.identity : CGAffineTransform(translationX: 0, y: 1000)
            }) { (_) in
                r.onNext()
                r.onCompleted()
            }
            
            return Disposables.create()
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        showPicker(isShow: false).bindNext {[weak self] in
            self?.dismiss(animated: true, completion: nil)
        }.addDisposableTo(disposeBag)
    }

}

extension PickerTypeViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return appDelegate.quantityTypes.count
    }
}

extension PickerTypeViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return appDelegate.quantityTypes[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let item = appDelegate.quantityTypes[row]
        self.currentItem = item
    }
}
