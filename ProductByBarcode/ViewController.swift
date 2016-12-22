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

protocol CheckBarcodeProtocol {
    var code: String? { get }
    var barcodeViewModel: BarcodeViewModel { get }
}

extension CheckBarcodeProtocol where Self: BaseController, Self: DisposeableProtocol {
    func checkBarcode() {
        barcodeViewModel.checkBarcode(code: code).observeOn(MainScheduler.instance).subscribe(onNext: { [weak self](type) in
            guard type != .none else {
                return
            }
            
            DispatchQueue.main.async {
                self?.performSegue(withIdentifier: "showEdit", sender: type)
            }
        
        }, onError: { [weak self](err) in
            self?.showErrorWith(error: err)
        }).addDisposableTo(disposeBag)
    }
}


class ViewController: BaseController, CheckBarcodeProtocol {

    fileprivate var reader: QRCodeReader!
    @IBOutlet weak var cameraContainer: UIView!
    
    @IBOutlet weak var torchButton: UIButton!
    @IBOutlet weak var lblStatus: UILabel!
    
    var barcodeType: BarcodeType?
    
    internal var code: String? {
        didSet {
            if code != nil {
                if reader != nil { reader.didFindCode = nil }
                
                self.checkBarcode()
            }
        }
    }
    var barcodeViewModel = BarcodeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Scan Barcode"
        barcodeViewModel.controller = self
        setAnimateForStatusLabel()
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
                self?.lblStatus.text = "Can't Open Camera"
            }).addDisposableTo(disposeBag)
        }
    }
    
    func setAnimateForStatusLabel() {
        
        let anim = CABasicAnimation(keyPath: "opacity")
        anim.fromValue = 1
        anim.toValue = 0
        anim.repeatCount = Float.infinity
        anim.duration = 0.4
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.lblStatus.layer.add(anim, forKey: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard reader != nil  else {
            commonInit()
            return
        }
        if !reader.isRunning {
            setupHandlerFindCode()
            reader.startScanning()
        }
    }
    
    
    override func handlerError() {
        print("Handler error")
        guard reader != nil else {
            return
        }
        setupHandlerFindCode()
        reader.startScanning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let controller = segue.destination as? EditProductController, let type = sender as? BarcodeType else {
            return
        }
        
        controller.barcodeType = type
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

