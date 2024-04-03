//
//  VerifyAccountRequestBody.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 01.04.2024.
//

import Foundation

struct VerifyAccountRequestBody: Encodable {
    let email: String
    let verificationCode: String
}
