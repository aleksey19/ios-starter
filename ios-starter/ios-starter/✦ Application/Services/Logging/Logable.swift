//
//  Logable.swift
//  Image Genarator
//
//  Created by Aleksey Bidnyk on 25.03.2024.
//

import Foundation

protocol Logable {
    func log(error: Error)
    func log(info: String)
    func log(warning: String)
}
