//
//  FCMManager.swift
//  Village
//
//  Created by 조성민 on 12/3/23.
//

import Foundation

final class FCMManager {
    
    static let shared = FCMManager()
    
    var fcmToken: String?
    
    init() {
        setNotification()
    }
    
    private func setNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(fcmTokenCalled), name: .fcmToken, object: nil)
    }
    
    @objc private func fcmTokenCalled() {
        sendFCMToken()
    }
    
    func sendFCMToken() {
        if JWTManager.shared.get() != nil {
            guard let token = fcmToken else { return }
            let endPoint = APIEndPoints.fcmTokenSend(fcmToken: token)
            Task {
                do {
                    try await APIProvider.shared.request(with: endPoint)
                }
            }
        }
    }
    
}
