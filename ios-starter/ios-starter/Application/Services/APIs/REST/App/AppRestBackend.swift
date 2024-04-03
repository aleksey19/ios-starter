//
//  AppRestBackend.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation

class AppRestBackend: NSObject {
    static let authorizationErrorNotification =
        Notification(name: Notification.Name(rawValue: "AuthorizationErrorNotification"))
    static let internetConnectionDissappearNotification =
        Notification(name: Notification.Name(rawValue: "InternetConnectionDissappearNotification"))
    static let internetConnectionAppearNotification =
        Notification(name: Notification.Name(rawValue: "InternetConnectionAppearNotification"))

    var cacheType: RESTService.CacheType {
        let config = ConfigLoader.parseConfig()
                        
        if config.flags?.shouldCacheAllNetworkData == true {
            return .all
        } else if config.flags?.shouldCacheOnlyImages == true {
            return .onlyImages
        }
        
        return .none
    }
    
    lazy var networkingService: RESTService = RESTService(cacheType: self.cacheType)

    var authorization: (type: String, token: String)?
    var authorizationRefresher: (( @escaping (Bool) -> Void) -> Void)?

    var appId: String?
    
    var baseHost = ""
    
    enum HostEndpoints: String {
        case users
        case notifications
    }
    
    func host(for endpoint: HostEndpoints) -> String {
        "https://" + endpoint.rawValue + "." + baseHost
    }

    override init() {
        super.init()

        networkingService.additionalHeaderParameters = {
            guard
                let tokenType = self.authorization?.type,
                let token = self.authorization?.token else {
                return [:]
            }
            
            return [
                "Authorization": "\(tokenType) \(token)"
            ]
        }

        networkingService.authoriationErrorHandler = { response in
            NotificationCenter.default.post(Self.authorizationErrorNotification)
        }

        networkingService.authoriationRefreshHandler = { completion in
            self.authorizationRefresher?(completion)
        }

        networkingService.internetConnectionReachableHandler = { connected in
            let notification: Notification

            if connected {
                notification = Self.internetConnectionAppearNotification
            } else {
                notification = Self.internetConnectionDissappearNotification
            }

            NotificationCenter.default.post(notification)
        }
    }
}
