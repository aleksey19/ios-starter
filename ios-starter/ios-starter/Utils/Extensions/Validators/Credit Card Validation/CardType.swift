//
//  Card Type.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import Foundation

enum CardType: String, Codable {
    case Unknown, Amex = "American Express", Visa, MasterCard, Discover
    
    static let allCards = [Amex, Visa, MasterCard, Discover]
    
    var regex : String {
        switch self {
        case .Amex:
            return "^3[47][0-9]{5,}$"
        case .Visa:
            return "^4[0-9]{6,}([0-9]{3})?$"
        case .MasterCard:
            return "^(5[1-5][0-9]{4}|677189)[0-9]{5,}$"
        case .Discover:
            return "^6(?:011|5[0-9]{2})[0-9]{3,}$"
        default:
            return ""
        }
    }
}
