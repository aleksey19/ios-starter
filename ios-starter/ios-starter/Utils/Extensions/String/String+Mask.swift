//
//  String+Mask.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import Foundation

extension String {
    static var phoneNumberMask = "(XXX) XXX-XXXX"
    static var phoneNumberInternationalMask = "XX (XXX) XXX-XXXX"
    static var amexMask = "XXXX XXXXXX XXXXX"
    static var defaultMask = "XXXX XXXX XXXX XXXX"
    static var visaMask = "XXXX XXXX XXXX XXXX XXX"
    static var postalCodeMask = "XXXXX-XXXX"
}

extension String {
    
    func withMask(mask: String = "XX-XX-XX") -> String {
        
        var newString = ""
        var oldString = self.components(separatedBy: CharacterSet(charactersIn: ",.\\ /-?!()")).joined()
        var index = mask.startIndex
        
        if self.count > mask.count {
            return oldString
        }
        
        for i in 0..<mask.count where oldString.count > 0 {
            
            index = mask.index(mask.startIndex, offsetBy: i)

            if mask[index] == "X" {
                newString.append(oldString[oldString.startIndex])
                oldString.remove(at: oldString.startIndex)
            } else {
                newString.append(mask[index])
            }
        }
        return newString
    }
}
