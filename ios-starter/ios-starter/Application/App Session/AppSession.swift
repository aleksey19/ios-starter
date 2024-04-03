//
//  AppSession.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import UIKit

class AppSession: NSObject {
    
    lazy private(set) var appRESTBackend: HTTPClient = {
        let httpService = HTTPService(host: ConfigLoader.parseConfig().apiUrl,
                                      apiVersion: "v1",
                                      retryCount: 1,
                                      refreshTokenCount: 1,
                                      notAuthorizedHandler: { [weak self] in
//            self?.sceneCoordinator.handleNotAuthorizedState()
        },
                                      serverErrorHandler: { [weak self] error in
//            self?.sceneCoordinator.handleServerError()
            self?.logout()
        },
                                      setAuthorizationTokenHandler: { [weak self] (token, refreshToken) in
            AccessToken.token = token
            AccessToken.refreshToken = refreshToken
        },
                                      refreshAuthorizationTokenHandler: { [weak self] in
            self?.refreshToken()
            AppLogger.shared.log(info: "Refresh authorisation token")
        })
        
//        if let authorization = self.authorization?.authorization {
//            backend.authorization = (authorization.type, authorization.token)
//        }
//
//        backend.authorizationRefresher = { [weak self] completion in
//            self?.refreshToken()
//        }
//
//        _ = NotificationCenter.default.addObserver(forName: AppRestBackend.authorizationErrorNotification.name,
//                                                   object: nil,
//                                                   queue: nil) { [weak self] _ in
//            self?.logout()
//        }
//
//        _ = NotificationCenter.default.addObserver(forName: AppRestBackend.internetConnectionDissappearNotification.name,
//                                                   object: nil,
//                                                   queue: nil) { _ in
//            #warning("It's happen when internet dissapear. To implement.")
//        }
//
//        _ = NotificationCenter.default.addObserver(forName: AppRestBackend.internetConnectionAppearNotification.name,
//                                                   object: nil,
//                                                   queue: nil) { _ in
//            #warning("It's happen when internet appear. Not called during first start when internet is on. To implement.")
//        }
        
        return httpService
    }()
    
    private(set) var sceneCoordinator: SceneCoordinatorable! = nil
    private(set) var remoteNotificationsService: RemoteNotificationsService! = nil
    
    // MARK: - Access token
    
    var sessionToken: String? {
        AccessToken.token
    }

    // MARK: - Init
    
    required init(window: UIWindow) {
        super.init()
        
        sceneCoordinator = SceneCoordinator(window: window,
                                            session: self)
        remoteNotificationsService = RemoteNotificationsService(sceneCoordinator: sceneCoordinator,
                                                                restService: appRESTBackend,
                                                                application: UIApplication.shared,
                                                                appSession: self)
    }
    
    // MARK: - Start
    
    func start() {
        cleanKeychainsIfFirstLaunch()
        
        sceneCoordinator.start()
        
        if sessionToken != nil {
//            sceneCoordinator.showSplash()
        } else {
//            sceneCoordinator.start()
        }
    }
    
    // MARK: - Register for remote notifications
    
    func registerForRemoteNotifications() {
        remoteNotificationsService.registerForRemoteNotifications()
    }
    
    // MARK: - Refresh token
    
    func refreshToken() {
        guard let refreshToken = AccessToken.refreshToken else {
            return
        }
        
        
    }
    
    // MARK: - Logout
    
    func logout() {
        remoteNotificationsService?.removeToken()
        clearData()
        
        AppLogger.shared.log(event: .signOut)
        AppLogger.shared.updateAttributes()
    }
    
    private func clearData() {
        AccessToken.token = nil
        AccessToken.refreshToken = nil
    }
    
    private func cleanKeychainsIfFirstLaunch() {
        if UserDefaults.isFirstLaunch() {
            clearData()
        }
    }
}
