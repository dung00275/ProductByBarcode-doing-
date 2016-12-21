//
//  ChooseTypeCell.swift
//  ProductByBarcode
//
//  Created by Dung Vu on 12/21/16.
//  Copyright © 2016 Zinio Pro. All rights reserved.
//

import Foundation
import UIKit

class ChooseTypeCell: UITableViewCell, InOutValueProtocol {
    
    @IBOutlet weak var textField: UITextField!
    var item : QuantityTypeItem? {
        didSet{
            self.textField.text = item?.value
        }
    }
    func getValue() -> InOutType {
        let type = Int(self.item?.value ?? "0") ?? 0
        return InOutType.quantityType(type: type)
    }
    
}
