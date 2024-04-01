//
//  UpdateUser.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation

extension AppRestBackend {
    
    typealias UpdateUserCompletion = ((Profile?, Error?) -> Void)
    typealias UpdateUserParameters = Profile
    
    func updateUser(with params: UpdateUserParameters,
                completion: @escaping UpdateUserCompletion) {
        let url = host(for: .users) + "/users"
        
        networkingService.connect(type: .put,
                                  url: url,
                                  inBodyParameters: params.stringDictionary,
                                  completion: completion)
    }
}
