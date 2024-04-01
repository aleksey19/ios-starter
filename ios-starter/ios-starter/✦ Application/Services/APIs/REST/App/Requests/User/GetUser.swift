//
//  GetUser.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation

extension AppRestBackend {
    
    typealias UserCompletion = ((Profile?, Error?) -> Void)
        
    func user(completion: @escaping SignInCompletion) {
        let url = host(for: .users) + "/users"
        
        networkingService.connect(type: .get,
                                  url: url,
                                  completion: completion)
    }
}
