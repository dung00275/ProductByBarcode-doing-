//
//  EditProductController.swift
//  ProductByBarcode
//
//  Created by Dung Vu on 12/21/16.
//  Copyright © 2016 Zinio Pro. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import ALLoadingView

enum ChooseImageType: CustomStringConvertible {
    case camera
    case library
    case cancel
    
    var description: String {
        switch self {
        case .camera:
            return "Camera"
        case .library:
            return "Library"
        case .cancel:
            return "Cancel"
        }
    }
}

struct ProductInfo {
    let images: [String]
    let productId: Int
    let quantity: Int
    let quantityType: String
}

enum ErrorChooseImage: Error {
    case camera
    case library
    case unknown
    var localizedDescription: String {
        switch self {
        case .camera:
            return "Can't Open Camera"
        case .library:
            return "Can't Open Photo Library"
        case .unknown:
            return "Unknown Error"
        }
    }
}

extension UIImagePickerControllerSourceType {
    var error: ErrorChooseImage {
        switch self {
        case .camera:
            return ErrorChooseImage.camera
        case .photoLibrary:
            return ErrorChooseImage.library
        default:
            return ErrorChooseImage.unknown
        }
    }
}


class EditProductController: UITableViewController, HandlerErrorController, DisposeableProtocol {
    let chooseImageSubject: PublishSubject<UIImage?> = PublishSubject()
    var disposeBag: DisposeBag! = DisposeBag()
    var currentType: QuantityTypeItem?
    var barcodeType: BarcodeType!
    lazy var loadingManager = ALLoadingView()
    let viewModel = EditProductViewModel()
    lazy var saveBtn: UIBarButtonItem = {
        return UIBarButtonItem(title: "Save", style: .plain, target: self, action: nil)
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = barcodeType.title
        setupSaveButton()
        loadingManager.blurredBackground = true
        setupLoading()
        
    }
    
    func setupSaveButton() {
        saveBtn = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(self.save))
        saveBtn.tintColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        self.navigationItem.rightBarButtonItem = saveBtn
    }
    
    func save() {
        self.checkInputProduct().flatMap { [weak self] p -> Observable<Void> in
            guard let weakSelf = self else{
                return Observable.empty()
            }
            return weakSelf.viewModel.saveProduct(p: p)
        }.trackActivity(self.trackLoading).subscribe(onNext: {[weak self] (_) in
            self?.success()
        }, onError: { [weak self](err) in
                self?.showErrorWith(error: err)
        }).addDisposableTo(disposeBag)

    }
    
    func success() {
        self.showAlertError(t: "Suceess", message: "Product is edited!!!").bindNext {[weak self] in
           _ = self?.navigationController?.popToRootViewController(animated: true)
        }.addDisposableTo(disposeBag)
    }
    
    func handlerError() {
        print("Handler Error")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    deinit {
        print("abc")
    }
    
    func checkInputProduct() -> Observable<ProductInfo> {
        let cells = tableView.visibleCells.flatMap({ $0 as? InOutValueProtocol })
        guard cells.count == 3 else {
            return Observable.error(ErrorCheckInputProduct.none)
        }
        
        var arrImage: [ImagesInfo] = []
        let productId = barcodeType.productId
        var quantity: Int = 0
        var quantityType: String = ""
        // Check productID
        guard productId != 0 else {
            return Observable.error(ErrorCheckInputProduct.none)
        }
        
        // Get Value
        do {
            try cells.forEach { (input) in
                let value = try input.getValue()
                
                switch value {
                case .image(let images):
                    arrImage += images
                case .quantity(let number):
                    quantity = number
                case .quantityType(let type):
                    quantityType = type
                }
            }
            
        }catch let err {
            guard let e = err as? ErrorCheckInputProduct else {
                return Observable.error(ErrorCheckInputProduct.none)
            }
            return Observable.error(e)
        }
        
        if arrImage.count == 0 {
            let info = ProductInfo(images: [],
                                   productId: productId,
                                   quantity: quantity,
                                   quantityType: quantityType)
            return Observable.just(info)
        }else {
            return viewModel.uploadImages(images: arrImage, with: "\(productId)").map({
                let info = ProductInfo(images: $0,
                                       productId: productId,
                                       quantity: quantity,
                                       quantityType: quantityType)
                return info
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? PickerTypeViewController {
            controller.currentItem = currentType
            controller.subjectChooseItem.bindNext({ [weak self](item) in
                self?.currentType = item
                
                self?.tableView.reloadRows(at: [IndexPath(item: 2, section: 0)], with: .none)
            }).addDisposableTo(disposeBag)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let imageCell = cell as? ChooseImageCell {
            imageCell.rootController = self
        }
        
        if let typeInput = cell as? ChooseTypeCell {
            typeInput.item = self.currentType
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.item {
        case 0:
            return 200
        default :
            return 50
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        self.view.endEditing(true)
        switch indexPath.item {
        case 2:
            self.performSegue(withIdentifier: "showPicker", sender: nil)
        default:
            break
        }
        
    }
    
    private func showAlertChoose() -> Observable<ChooseImageType> {
        self.view.endEditing(true)
        return Observable.create({[unowned self] (r) -> Disposable in
            let actionSheet = UIAlertController(title: "Input Image", message: nil, preferredStyle: .actionSheet)
            let actionCamera = UIAlertAction(title: ChooseImageType.camera.description, style: .default) { (_) in
                r.onNext(.camera)
                r.onCompleted()
            }
            let actionLib = UIAlertAction(title: ChooseImageType.library.description, style: .default) { (_) in
                r.onNext(.library)
                r.onCompleted()
            }
            let actionCancel = UIAlertAction(title: ChooseImageType.cancel.description, style: .destructive) { (_) in
                r.onNext(.cancel)
                r.onCompleted()
            }
            
            actionSheet.addAction(actionCamera)
            actionSheet.addAction(actionLib)
            actionSheet.addAction(actionCancel)
            
            self.present(actionSheet, animated: true, completion: nil)
            
            return Disposables.create {
               actionSheet.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    func chooseTypeImage() -> Observable<ImagesInfo> {
        
        return showAlertChoose().flatMap({ [unowned self]type in
            self.chooseImage(with: type)
        })
    }
    
}

extension EditProductController {
    
    fileprivate func showPickerChoose(type : UIImagePickerControllerSourceType) -> Observable<ImagesInfo> {
        if UIImagePickerController.isSourceTypeAvailable(type) {
            let productId = self.barcodeType.productId
            return Observable.create({ [unowned self](r) -> Disposable in
                let pickerController = UIImagePickerController()
                pickerController.sourceType = type
                pickerController.allowsEditing = true
                
                _ = pickerController.rx.didFinishPickingMediaWithInfo.bindNext({(d) in
                    let image = d[UIImagePickerControllerEditedImage] as? UIImage
                    var url: URL?
                    if let i = image {
                        let d = UIImageJPEGRepresentation(i, 0.3)
                        let local = URL.cacheDirectory()!.appendingPathComponent("\(productId)_\(Date().timeIntervalSince1970).jpg")
                        try? d?.write(to: local)
                        url = local
                    }
                    
                    let info = ImagesInfo(image: image, path: url)
                    
                    r.onNext(info)
                    r.onCompleted()
                    
                })
                
                _ = pickerController.rx.didCancel.bindNext({(_) in
                    print("cancel")
                    r.onCompleted()
                })
                
                self.present(pickerController, animated: true, completion: nil)
                
                return Disposables.create {
                    pickerController.dismiss(animated: true, completion: nil)
                }
            })
        }
        else {
            return showAlertError(message: type.error.localizedDescription).flatMap({ (_)  in
                return Observable.empty()
            })
        }
    }
    
    
    fileprivate func chooseImage(with action: ChooseImageType) -> Observable<ImagesInfo> {
        switch action {
        case .camera:
            return showPickerChoose(type: .camera)
        case .library:
            return showPickerChoose(type: .photoLibrary)
        default:
            return Observable.empty()
        }
    }
}

