//
//  Response.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation

class EmptyResponse: Decodable {
    var success: Bool
    var errors: [String]?

    enum CodingKeys: String, CodingKey {
        case success, errors
    }
}

class Response<T: Decodable>: Decodable {
    var success: Bool
    var errors: [String]?
    var data: T?
    var code: Int?

    enum CodingKeys: String, CodingKey {
        case success, errors, data, code = "httpCode"
    }
}
