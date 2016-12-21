//
//  Model.swift
//  ProductByBarcode
//
//  Created by Dung Vu on 12/20/16.
//  Copyright © 2016 Zinio Pro. All rights reserved.
//

import Foundation
import ObjectMapper

class QuantityTypeItem: NSObject, NSCoding, Mappable {
    
    var name: String?
    var value: String?
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: "_name") as? String,
            let value = aDecoder.decodeObject(forKey: "_value") as? String else {
            return nil
        }
        self.init()
        self.name = name
        self.value = value
    }
    
    func encode(with aCoder: NSCoder) {
       aCoder.encode(name, forKey: "_name")
       aCoder.encode(value, forKey: "_value")
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        value <- map["value"]
    }
}


struct ProductItem: Mappable {
    var productId: Int?
    var barcode: String?
    var type: String?

    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        productId <- map["productId"]
        barcode <- map["barcode"]
        type <- map["type"]
    }
}


struct CheckBarcodeItem: Mappable {
    var id: String?
    var barcode: String?
    var quantity: String?
    var price: String?
    var selling_price: String?
    var name: String?
    var description: String?
    var created_at: Date?
    var updated_at: Date?
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        barcode <- map["barcode"]
        quantity <- map["quantity"]
        price <- map["price"]
        selling_price <- map["selling_price"]
        name <- map["name"]
        description <- map["description"]
        created_at <- (map["created_at"], DateTransform())
        updated_at <- (map["updated_at"], DateTransform())
    }
}

struct ModelCheckBarcode {
    var items: [CheckBarcodeItem]?
}
