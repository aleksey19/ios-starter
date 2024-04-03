//
//  SignUpRequestBody.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 01.04.2024.
//

import Foundation

struct SignUpRequestBody: Encodable {
    let email: String
    let fullName: String
    let address1: String
    let address2: String?
    let city: String
    let state: String
    let zip: String
    let accountType: Int
    let phoneNumber: String
}
