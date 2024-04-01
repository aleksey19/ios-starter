//
//  Encodable+Package.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation

extension Encodable {
    func serialization() -> Data? {
        do {
            return try JSONEncoder().encode(self)
        } catch {
            return nil
        }
    }

    func serialization() -> String? {
        do {
            let data = try JSONEncoder().encode(self)

            return String.init(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
}
