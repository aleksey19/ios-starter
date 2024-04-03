//
//  HTTPRequest.swift
//  Image Genarator
//
//  Created by Aleksey Bidnyk on 25.03.2024.
//

import Foundation

enum HTTPMethod: String {
    case post
    case get
    case delete
    case put
    case patch
}

protocol HTTPRequest {
    var method: HTTPMethod { get }
    var path: String { get }
    var query: [URLQueryItem]? { get }
    var body: Encodable? { get }
}
