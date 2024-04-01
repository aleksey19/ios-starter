//
//  SignUpRequest.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation

extension AppRestBackend {
    
    typealias SignUpCompletion = ((TokensResponse?, Error?) -> Void)

    struct SignUpParameters: Encodable {
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
    
    func signUp(with params: SignUpParameters,
                completion: @escaping SignUpCompletion) {
        let url = host(for: .users) + "/sign-up"
        
        networkingService.connect(type: .post,
                                  url: url,
                                  inBodyParameters: params.stringDictionary,
                                  completion: completion)
    }
}
