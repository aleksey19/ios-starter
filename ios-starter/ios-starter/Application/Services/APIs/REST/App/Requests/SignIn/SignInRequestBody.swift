//
//  SignInRequestBody.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 01.04.2024.
//

import Foundation

struct SignInRequestBody: Encodable {
    let email: String
    let password: String
}
