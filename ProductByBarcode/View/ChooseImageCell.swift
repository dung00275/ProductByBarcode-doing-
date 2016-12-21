//
//  ChooseImageCell.swift
//  ProductByBarcode
//
//  Created by Dung Vu on 12/21/16.
//  Copyright © 2016 Zinio Pro. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa


enum InOutType {
    case image(images : [ImagesInfo])
    case quantity(number: Int)
    case quantityType(type: Int)
}

protocol InOutValueProtocol {
    func getValue() -> InOutType
}


let kMaxItems = 6
let kTagImageViewCell = 101
let kImageCellIdentify = "ImageCell"

struct ImagesInfo {
    let image: UIImage?
    let path: URL?
}

class ChooseImageCell: UITableViewCell, InOutValueProtocol {
    

    var disposeBag: DisposeBag! = DisposeBag()
    @IBOutlet weak var collectionView: UICollectionView!
    weak var rootController: EditProductController?
    var images : [ImagesInfo] = []
    var isLessThanMax: Bool {
        return images.count < kMaxItems
    }
    
    override func prepareForReuse() {
        disposeBag = nil
        disposeBag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    func getValue() -> InOutType {
        return InOutType.image(images: images)
    }
    
}

extension ChooseImageCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        let isLastIndex = indexPath.item == images.count
        checkCondition: if isLastIndex {
            // Add image
            
            rootController?.chooseTypeImage().bindNext({ [weak self](newInfo) in
                
                self?.images.insert(newInfo, at: 0)
                if (self?.images.count ?? 0) < kMaxItems {
                     self?.collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
                }else {
                    self?.collectionView.reloadData()
                }
               
            }).addDisposableTo(disposeBag)
        }
    }
}

extension ChooseImageCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isLessThanMax ? images.count + 1 : images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kImageCellIdentify, for: indexPath)
        let isLastIndex = indexPath.item == images.count
        
        checkCondition: if isLastIndex {
            (cell.viewWithTag(kTagImageViewCell) as? UIImageView)?.image = UIImage(named: "add")
            (cell as? ImageCollectionViewCell)?.resetContainer()
        }else {
            let item = images[indexPath.item]
            (cell.viewWithTag(kTagImageViewCell) as? UIImageView)?.image = item.image
            guard let imageCell = cell as? ImageCollectionViewCell else {
                break checkCondition
            }
            imageCell.delegate = self
            imageCell.isNeedHandlerLongGesture = true
        }
        
        
        return cell
    }
}
extension ChooseImageCell: DeleteImageProtocol {
    func deleteImageAt(cell: UICollectionViewCell) {
        guard let index = collectionView.indexPath(for: cell) else {
            return
        }
        
        images.remove(at: index.item)
        collectionView.reloadData()
    }
}
