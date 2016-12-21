//
//  ImageCollectionViewCell.swift
//  ProductByBarcode
//
//  Created by Dung Vu on 12/21/16.
//  Copyright © 2016 Zinio Pro. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

enum StateDelete {
    case none
    case inDelete
}

protocol DeleteImageProtocol: class {
    func deleteImageAt(cell : UICollectionViewCell)
}

class ImageCollectionViewCell: UICollectionViewCell {
    
    var disposeBag: DisposeBag! = DisposeBag()
    var isNeedHandlerLongGesture: Bool = false
    
    weak var delegate: DeleteImageProtocol?
    var state: StateDelete = .none
    @IBOutlet weak var containerDeleteView: UIView!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func resetContainer() {
        state = .none
        isNeedHandlerLongGesture = false
        self.containerDeleteView.isHidden = true
        self.containerDeleteView.alpha = 0
        isNeedHandlerLongGesture = false
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLongGesture()
        
        btnCancel.rx.tap.bindNext{[unowned self] in
            self.showViewDelete(isShow: false)
        }.addDisposableTo(disposeBag)
        
        btnDelete.rx.tap.bindNext{[unowned self] in
            self.delegate?.deleteImageAt(cell: self)
        }.addDisposableTo(disposeBag)
    }
    
    func setupLongGesture() {
        let gesture = UILongPressGestureRecognizer(target: self, action: nil)
        gesture.minimumPressDuration = 1
        gesture.rx.event.bindNext { [unowned self](gesture) in
            guard self.isNeedHandlerLongGesture else {
                return
            }
            self.showViewDelete()
        }.addDisposableTo(disposeBag)
        self.addGestureRecognizer(gesture)
    }
    
    func showViewDelete(isShow: Bool = true) {
        let alpha: CGFloat = isShow ? 1 : 0
        self.state = isShow ? .inDelete : .none
        self.containerDeleteView.isHidden = false
        UIView.animate(withDuration: 0.22, animations: {
            self.containerDeleteView.alpha = alpha
        }) { (_) in
            self.containerDeleteView.isHidden = isShow.negative
        }
    }
    
}
