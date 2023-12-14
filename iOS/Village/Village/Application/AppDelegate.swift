//
//  AppDelegate.swift
//  Village
//
//  Created by 조성민 on 11/8/23.
//

import UIKit
import UserNotifications
import FirebaseCore
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UINavigationBar.appearance().tintColor = .primary500
        registerForPushNotifications()
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    
}

extension AppDelegate {
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
                guard granted else { return }
                self?.getNotificationSettings()
            }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let content = response.notification.request.content.userInfo
        guard let windowSceneDelegate = response.targetScene?.delegate as? UIWindowSceneDelegate,
              let windowScene = windowSceneDelegate.window,
              let rootViewController = windowScene?.rootViewController as? AppTabBarController,
              let navigationController = rootViewController.selectedViewController as? UINavigationController,
              let roomIDString = content["room_id"] as? String,
              let roomID = Int(roomIDString) else {
            completionHandler()
            return
        }
        
        navigationController.pushViewController(ChatRoomViewController(viewModel: ChatRoomViewModel(roomID: roomID)), animated: true)
        completionHandler()
    }
    
}

extension AppDelegate: MessagingDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        FCMManager.shared.fcmToken = fcmToken
        NotificationCenter.default.post(
            name: .fcmToken,
            object: nil,
            userInfo: dataDict
        )
    }
    
}
