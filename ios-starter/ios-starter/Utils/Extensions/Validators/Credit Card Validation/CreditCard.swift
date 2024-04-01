//
//  CreditCard.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import Foundation

class CreditCard {
    static func validate(_ cardNumber: String) -> (type: CardType, valid: Bool) {
        // Get only numbers from the input string
        let input = cardNumber
        let numberOnly = input.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        var type: CardType = .Unknown
        var formatted = ""
        var valid = false
        
        // Detect card type
        for card in CardType.allCards {
            if (matchesRegex(regex: card.regex, text: numberOnly)) {
                type = card
                break
            }
        }
        
        // Luhn check validity
        valid = luhnCheck(numberOnly)
        
        // Format
        var formatted4 = ""
        for character in numberOnly {
            if formatted4.count == 4 {
                formatted += formatted4 + " "
                formatted4 = ""
            }
            formatted4.append(character)
        }
        
        formatted += formatted4
        
        // Return the tuple
        return (type, valid)
    }
    
    private static func matchesRegex(regex: String!, text: String!) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [.caseInsensitive])
            let nsString = text as NSString
            let match = regex.firstMatch(in: text, options: [], range: NSMakeRange(0, nsString.length))
            return (match != nil)
        } catch {
            return false
        }
    }
    
    private static func luhnCheck(_ number: String) -> Bool {
        var sum = 0
        let digitStrings = number.reversed().map { String($0) }
        
        for tuple in digitStrings.enumerated() {
            if let digit = Int(tuple.element) {
                let odd = tuple.offset % 2 == 1
                
                switch (odd, digit) {
                case (true, 9):
                    sum += 9
                case (true, 0...8):
                    sum += (digit * 2) % 9
                default:
                    sum += digit
                }
            } else {
                return false
            }
        }
        return sum % 10 == 0
    }
}
