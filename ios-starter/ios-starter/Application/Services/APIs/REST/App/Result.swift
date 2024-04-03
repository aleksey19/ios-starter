//
//  Result.swift
//  Braums
//
//  Created by Aleksey Bidnyk on 08.08.2023.
//

import Foundation

enum Result<T: Decodable> {
    case success(T)
    case failure(Error)
}
