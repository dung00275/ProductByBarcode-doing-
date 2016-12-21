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
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let imageCell = cell as? ChooseImageCell {
            imageCell.rootController = self
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.item {
        case 0:
            return 200
        case 1:
            return 80
        default:
            break
        }
        
        return 44
    }
    
    private func showAlertChoose() -> Observable<ChooseImageType> {
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

