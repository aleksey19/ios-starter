//
//  NSObject+ClassName.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import Foundation

extension NSObject {
    class var className: String {
        String(describing: self)
    }
}
