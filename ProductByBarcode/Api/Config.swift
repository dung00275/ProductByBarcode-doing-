//
//  Config.swift
//  ProductByBarcode
//
//  Created by Dung Vu on 12/20/16.
//  Copyright © 2016 Zinio Pro. All rights reserved.
//

import Foundation
import Alamofire

struct API {
    static let baseURL = "http://badila.co:2314/web-service/services/"
}

enum Router {
    case checkBarcode(code: String?)
    case createProduct(code: String?)
    case updateProduct(code: String?)
    case getQuantityTypes
    case uploadImage(fileName: String?, productId: Int)
    case saveProduct(images: [String], productId: Int, quantity: Int, quantityType: String)
    
    var method: HTTPMethod {
        switch self {
        case .checkBarcode:
            return .get
        case .createProduct:
            return .get
        case .updateProduct:
            return .get
        case .getQuantityTypes:
            return .get
        case .uploadImage:
            return .post
        case .saveProduct:
            return .post
        }
    }
    
    
    var params: [String: Any] {
        var parameters: [String: Any] = [:]
        switch self {
        case .checkBarcode(let code):
            parameters["barcode"] = code
        case .createProduct(let code):
            parameters["newProduct"] = "1"
            parameters["barcode"] = code
            parameters["action"] = "new"
        case .updateProduct(let code):
            parameters["newProduct"] = "1"
            parameters["barcode"] = code
            parameters["action"] = "update"
        case .getQuantityTypes:
            break
        case .saveProduct(let images,let productId,let quantity,let quantityType):
            parameters["images"] = images
            parameters["productId"] = productId
            parameters["quantity"] = quantity
            parameters["quantityType"] = quantityType
        case .uploadImage(let fileName, let productId):
            parameters["fileName"] = fileName
            parameters["productId"] = productId
        }
        return parameters
    }
    
    var path: String {
        switch self {
        case .checkBarcode:
            return API.baseURL + "checkBarcode"
        case .createProduct, .updateProduct:
            return API.baseURL + "processProduct"
        case .getQuantityTypes:
            return API.baseURL + "getQuantityTypes"
        case .uploadImage:
            return API.baseURL + "saveImages"
        case .saveProduct:
            return API.baseURL + "updateProduct"
        }
    }
}
