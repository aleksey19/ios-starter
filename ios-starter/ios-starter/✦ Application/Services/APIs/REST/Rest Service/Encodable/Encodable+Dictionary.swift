//
//  Encodable+Dictionary.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation

extension Encodable {
    subscript(key: String) -> Any? {
        return dictionary?[key]
    }

    var dictionary: [String: Any]? {
        do {
            let data = try JSONEncoder().encode(self)
            let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]

            return dictionary
        } catch {
            print(error)
            return nil
        }
    }

    var stringDictionary: [String: String]? {
        do {
            
            let data = try JSONEncoder().encode(self)  
            let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
            
            var stringDictionary: [String:String] = [:]

            dictionary?.forEach({ (key, value) in
                if value is Bool,
                    let value = value as? Bool {
                    stringDictionary[key] = "\(value ? "true" : "false")"
                    return
                }
                
                stringDictionary[key] = "\(value)"
            })
            
            return stringDictionary
        } catch {
            print(error)
            return nil
        }
    }
}
