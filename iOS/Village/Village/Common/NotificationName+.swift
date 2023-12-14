//
//  NotificationName+.swift
//  Village
//
//  Created by 조성민 on 11/29/23.
//

import Foundation

extension Notification.Name {
    
    static let openChatRoom = Notification.Name("OpenChatRoom")
    static let fcmToken = Notification.Name("FCMToken")
    static let loginSucceed = Notification.Name("LoginSucceed")
    static let shouldLogin = Notification.Name("ShouldLogin")
    static let postEdited = Notification.Name("PostEdited")
    static let postDeleted = Notification.Name("PostDeleted")
    static let postCreated = Notification.Name("PostCreated")
    static let postRefreshAll = Notification.Name("PostRefreshAll")
  
}
