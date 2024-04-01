//
//  AppSession.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import UIKit

class AppSession: NSObject {
    
    lazy private(set) var appRESTBackend: AppRestBackend = {
        let backend = AppRestBackend()
        backend.baseHost = ConfigLoader.parseConfig().apiUrl

        if let authorization = self.authorization?.authorization {
            backend.authorization = (authorization.type, authorization.token)
        }

        backend.authorizationRefresher = { [weak self] completion in
            self?.refreshToken()
        }
        
        _ = NotificationCenter.default.addObserver(forName: AppRestBackend.authorizationErrorNotification.name,
                                                   object: nil,
                                                   queue: nil) { [weak self] _ in
            self?.logout()
        }
        
        _ = NotificationCenter.default.addObserver(forName: AppRestBackend.internetConnectionDissappearNotification.name,
                                                   object: nil,
                                                   queue: nil) { _ in
            #warning("It's happen when internet dissapear. To implement.")
        }
        
        _ = NotificationCenter.default.addObserver(forName: AppRestBackend.internetConnectionAppearNotification.name,
                                                   object: nil,
                                                   queue: nil) { _ in
            #warning("It's happen when internet appear. Not called during first start when internet is on. To implement.")
        }
        
        return backend
    }()
    
    private(set) var sceneCoordinator: SceneCoordinatorable! = nil
    private(set) var remoteNotificationsService: RemoteNotificationsService! = nil
    
    // MARK: - Authorization
    
    private(set) var authorization: Authorization? = nil
    
    func set(authorization: Authorization) {
        self.authorization = authorization
        
        guard let authorization = authorization.authorization
        else {
            return
        }
        
        appRESTBackend.authorization = (authorization.type, authorization.token)
    }

    // MARK: - Init
    
    required init(window: UIWindow) {
        super.init()
        
        sceneCoordinator = SceneCoordinator(window: window,
                                            session: self,
                                            isActiveSession: authorization != nil)
        remoteNotificationsService = RemoteNotificationsService(sceneCoordinator: sceneCoordinator,
                                                                restService: appRESTBackend,
                                                                application: UIApplication.shared,
                                                                appSession: self)
    }
    
    // MARK: - Start
    
    func start() {
        sceneCoordinator.start()
        
        cleanKeychainsIfFirstLaunch()
        
        guard authorization != nil else {
            return
        }
        
        
//        sceneCoordinator.start()
    }
    
    // MARK: - Register for remote notifications
    
    func registerForRemoteNotifications() {
        remoteNotificationsService.registerForRemoteNotifications()
    }
    
    // MARK: - Refresh token
    
    func refreshToken() {
        guard let refreshToken = self.authorization?.authorization?.refreshToken else {
            return
        }
    }
    
    // MARK: - Logout
    
    func logout() {
        clearData()
    }
    
    private func clearData() {
        authorization = nil
    }
    
    private func cleanKeychainsIfFirstLaunch() {
        if UserDefaults.isFirstLaunch() {
            authorization = nil
        }
    }
}

extension AppSession {
    // MARK: - Properties. User
    private static let UserlAccessKey: String = "app_user_access_key"
    
    var user: Profile? {
        get {
            if let data = UserDefaults.standard.data(forKey: AppSession.UserlAccessKey) {
                return try? PropertyListDecoder().decode(Profile.self, from: data)
            }
            return nil
        }
        set {
            UserDefaults.standard.set(try? PropertyListEncoder().encode(newValue), forKey: AppSession.UserlAccessKey)
        }
    }
}
