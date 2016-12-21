//
//  ViewController.swift
//  ProductByBarcode
//
//  Created by Dung Vu on 12/20/16.
//  Copyright © 2016 Zinio Pro. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ALLoadingView
class ViewController: BaseController {

    fileprivate var reader: QRCodeReader!
    @IBOutlet weak var cameraContainer: UIView!
    
    @IBOutlet weak var torchButton: UIButton!
    @IBOutlet weak var lblStatus: UILabel!
    
    fileprivate var code: String? {
        didSet {
            if code != nil {
                if reader != nil { reader.didFindCode = nil }
                
                barcodeViewModel.checkBarcode(code: code).subscribe(onNext: { (_) in
                    print("abc")
                }, onError: { [weak self](err) in
                    self?.showErrorWith(error: err)
                }).addDisposableTo(disposeBag)
            }
        }
    }
    var barcodeViewModel = BarcodeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Scan Barcode"
        barcodeViewModel.controller = self
    }
    
    fileprivate func commonInit() {
        if QRCodeReader.isAvailable() {
            reader = QRCodeReader()
            self.torchButton.isEnabled = reader.isTorchAvailable
            if reader.isTorchAvailable {
                self.torchButton.rx.tap.bindNext { [weak self]_ in
                    self?.reader.toggleTorch()
                }.addDisposableTo(disposeBag)
            }
            
            let previewLayer = reader.previewLayer
            
            var frame = UIScreen.main.bounds
            frame.size.height -= 64
            
            previewLayer.frame = frame
            cameraContainer.layer.insertSublayer(previewLayer, at: 0)
            setupHandlerFindCode()
            self.lblStatus.text = "Scanning barcode ..."
            reader.startScanning()
            
        } else {
            showAlertError(message: "Can't setup camera. Please check in Setting").bindNext({ [weak self](_) in
                self?.lblStatus.text = "Can't Open Caamera"
            }).addDisposableTo(disposeBag)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard reader != nil, reader.isRunning.negative  else {
            commonInit()
            return
        }
        if !reader.isRunning {
            reader.startScanning()
        }
    }
    
    
    override func handlerError() {
        print("Handler error")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
// MARK: -- Setup QR code
extension ViewController {
    
    
    fileprivate func setupHandlerFindCode() {
        
        guard reader.didFindCode == nil else {
            return
        }
        reader.didFindCode = {[weak self] r in
            print(r.value)
            self?.code = r.value
        }
        
        
    }
}

