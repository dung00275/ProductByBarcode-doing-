//
//  InputQuantityCell.swift
//  ProductByBarcode
//
//  Created by Dung Vu on 12/21/16.
//  Copyright © 2016 Zinio Pro. All rights reserved.
//

import Foundation
import UIKit

enum ErrorCheckInputProduct: Error {
    case quantity
    case type
    case none
    
    var localizedDescription: String {
        switch self {
        case .quantity:
            return "Not Input Quantity Yet!!!"
        case .type:
            return "Not Input Type Product Yet!!!"
        case .none:
            return "Error Unknown!!!"
        }
    }
}

class InputQuantityCell: UITableViewCell, InOutValueProtocol {
    @IBOutlet weak var textField: UITextField!
    func getValue() throws -> InOutType {
        guard let text = textField.text , text.characters.count > 0 else {
            throw ErrorCheckInputProduct.quantity
        }
        
        guard let quantity = Int(text) else {
            throw ErrorCheckInputProduct.quantity
        }
        
        return InOutType.quantity(number: quantity)
    }
}
