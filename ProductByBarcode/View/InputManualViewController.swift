//
//  InputManualViewController.swift
//  ProductByBarcode
//
//  Created by Dung Vu on 12/21/16.
//  Copyright © 2016 Zinio Pro. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class InputManualViewController: BaseController, CheckBarcodeProtocol {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var btnCheck: UIButton!
    
    internal var code: String? {
        didSet {
            if code != nil {
                self.checkBarcode()
            }
        }
    }
    var barcodeViewModel = BarcodeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barcodeViewModel.controller = self
        textField.rx.text.asObservable().map({
            ($0 ?? "").characters.count > 5
        }).bindTo(btnCheck.rx.isEnabled).addDisposableTo(disposeBag)
        
        btnCheck.rx.tap.bindNext {[unowned self] in
            self.code = self.textField.text
        }.addDisposableTo(disposeBag)
        
        NotificationCenter.default.rx.notification(Notification.Name.UIKeyboardWillShow).bindNext {[weak self] (notify) in
            print("abc")
            guard let userInfo = notify.userInfo as? [String : Any] else {
                return
            }
            
            let frameEnd = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? CGRect.zero
            let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double) ?? 0
            
            UIView.animate(withDuration: duration, animations: { 
                self?.btnCheck.transform = CGAffineTransform(translationX: 0, y: -frameEnd.size.height)
            })
        
        }.addDisposableTo(disposeBag)
        
        NotificationCenter.default.rx.notification(Notification.Name.UIKeyboardWillHide).bindNext { [weak self](notify) in
            guard let userInfo = notify.userInfo as? [String : Any] else {
                return
            }
            let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double) ?? 0
            
            UIView.animate(withDuration: duration, animations: {
                self?.btnCheck.transform = CGAffineTransform.identity
            })
            
            }.addDisposableTo(disposeBag)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let controller = segue.destination as? EditProductController, let type = sender as? BarcodeType else {
            return
        }
        
        controller.barcodeType = type
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    
}
