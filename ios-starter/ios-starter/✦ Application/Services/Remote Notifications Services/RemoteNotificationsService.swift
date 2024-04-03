//
//  RemoteNotificationsService.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 2.04.2024.
//

import UIKit
import UserNotifications
import FirebaseMessaging

class RemoteNotificationsService: NSObject {
    
    private weak var sceneCoordinator: SceneCoordinatorable?
    private weak var restService: HTTPClient?
    private weak var application: UIApplication?
    private weak var appSession: AppSession?
    
    private var fcmToken: String?
    
    /// Storing notification in background state.
    /// Used for screen transition after session will be restored.
    ///
    private var notification: RemoteNotification?
    
    // MARK: - Init
    
    init(sceneCoordinator: SceneCoordinatorable,
         restService: HTTPClient,
         application: UIApplication,
         appSession: AppSession) {
        self.sceneCoordinator = sceneCoordinator
        self.restService = restService
        self.application = application
        self.appSession = appSession

        super.init()

        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
    }
    
    // MARK: - Register for push notifications
    /// Invoke after successfull login or verification of the new user.
    func registerForRemoteNotifications() {
        executeOnMainThread {
            UNUserNotificationCenter.current().delegate = self
            Messaging.messaging().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions,
                                                                    completionHandler: {_, _ in })
            
            self.application?.registerForRemoteNotifications()
        }
        
        if let token = Messaging.messaging().fcmToken {
            sendToken(token)
        }
    }
    
    // MARK: - Send/Remove token
    
    private func sendToken(_ token: String) {
        guard appSession?.sessionToken != nil,
              token != fcmToken
        else {
            return
        }

        self.fcmToken = token

        restService?.registerPushNotificationsToken(with: token,
                                                   type: "iOS") { result in
            
        }
    }
    
    func removeToken() {
        guard let token = self.fcmToken
        else {
            return
        }
        
        restService?.unregisterPushNotificationsToken(token) { result in
            
        }
    }
}

extension RemoteNotificationsService {
    // MARK: - Parse notification
        
    private func parse(notification: UNNotification) -> RemoteNotification? {
        let info = notification.request.content.userInfo

        guard let data = try? JSONSerialization.data(withJSONObject: info, options: .prettyPrinted),
              let notification = try? JSONDecoder().decode(BaseNotification.self, from: data) else {
            return nil
        }

        print("### \(String(data: data, encoding: .utf8) ?? "")")

        return notification
    }
}

extension RemoteNotificationsService {
    // MARK: - Handle notification. Process delayed transition
    
    /// Handle delayed notification in background. Show appropriate screen and clear notification.
    func handleNotificationIfBackground() {
        
        self.notification = nil
        
        fatalError("🚫 Complete handleNotificationIfBackground:")
    }
    
    /// Handle notification in foreground. Show appropriate screen.
    func handleNotificationIfForeground(notification: RemoteNotification) {
                
        fatalError("🚫 Complete handleNotificationIfForeground:")
    }
}

extension RemoteNotificationsService: UNUserNotificationCenterDelegate {
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        self.notification = parse(notification: response.notification)
        
        if sceneCoordinator?.canPerformTransitionForPushNotification == true,
           let _ = self.notification {
            handleNotificationIfBackground()
        }
    }
    
    // Invokes if notifications arrives in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .sound])
        
        if sceneCoordinator?.canPerformTransitionForPushNotification == true,
           let notification = parse(notification: notification) {
            handleNotificationIfForeground(notification: notification)
        }
    }
    
}

extension RemoteNotificationsService: MessagingDelegate {
    // MARK: - MessagingDelegate
    
    func messaging(_ messaging: Messaging,
                   didReceiveRegistrationToken fcmToken: String?) {
        print("♻️ FCM Token: \(fcmToken ?? "❗️ no fcm token")")
        
        if let fcmToken = fcmToken {
            sendToken(fcmToken)
        } else {
            self.fcmToken = nil
        }
    }
    
}
