//
//  InputQuantityCell.swift
//  ProductByBarcode
//
//  Created by Dung Vu on 12/21/16.
//  Copyright © 2016 Zinio Pro. All rights reserved.
//

import Foundation
import UIKit

class InputQuantityCell: UITableViewCell, InOutValueProtocol {
    @IBOutlet weak var textField: UITextField!
    func getValue() -> InOutType {
        let quantity = Int(textField.text ?? "0") ?? 0
        return InOutType.quantity(number: quantity)
    }
}
