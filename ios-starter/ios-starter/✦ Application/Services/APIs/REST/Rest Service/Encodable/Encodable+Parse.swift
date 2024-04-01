//
//  Encodable+Parse.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation

extension Data {
    func parse<T: Decodable>() -> T? {
        do {
            return try JSONDecoder().decode(T.self, from: self)
        } catch {
            return nil
        }
    }
}

extension String {
    func parse<T: Decodable>() -> T? {
        do {
            guard let data = self.data(using: .utf8) else {
                return nil
            }

            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            return nil
        }
    }
}
