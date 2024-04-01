//
//  ImageRequest.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation

extension AppRestBackend {
    
    func image(url: String,
               inPathParameters: [String: String]? = nil,
               completion: ((Data?, Error?) -> Void)?) {
        networkingService.image(url: url,
                                inPathParameters: inPathParameters,
                                completion: completion)
    }
}
