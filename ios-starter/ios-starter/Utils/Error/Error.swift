//
//  Error.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import Foundation

enum AppError: Error {
    case apiError(String)
    case mappingError(String)
    case customError(String)
    case unknownError
}

extension AppError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .apiError(let message),
             .mappingError(let message),
             .customError(let message):
            return message
        case .unknownError:
            return "Something went wrong"
        }
    }
}
