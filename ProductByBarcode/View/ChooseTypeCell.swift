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
    
    func getValue() throws -> InOutType {
        guard let value = item?.value  else {
            throw ErrorCheckInputProduct.type
        }
        
        return InOutType.quantityType(type: value)
    }
    
}
