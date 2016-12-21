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
    var error: Error {
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


class EditProductController: UITableViewController, HandlerErrorController {
    
    let chooseImageSubject: PublishSubject<UIImage?> = PublishSubject()
    let diposeBag = DisposeBag()
    var currentType: QuantityTypeItem?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Edit Product"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? PickerTypeViewController {
            controller.currentItem = currentType
            controller.subjectChooseItem.bindNext({ [weak self](item) in
                self?.currentType = item
                
                self?.tableView.reloadRows(at: [IndexPath(item: 2, section: 0)], with: .none)
            }).addDisposableTo(diposeBag)
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
            
            return Observable.create({ [unowned self](r) -> Disposable in
                let pickerController = UIImagePickerController()
                pickerController.sourceType = type
                pickerController.allowsEditing = true
                
                _ = pickerController.rx.didFinishPickingMediaWithInfo.bindNext({(d) in
                    let image = d[UIImagePickerControllerEditedImage] as? UIImage
                    let info = ImagesInfo(image: image, path: nil)
                    
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

