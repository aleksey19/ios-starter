//
//  Tokens.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation

struct Tokens: Decodable {
    let token: String
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case token, refreshToken
    }
}
