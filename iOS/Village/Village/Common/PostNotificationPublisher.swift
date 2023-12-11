//
//  PostNotificationPublisher.swift
//  Village
//
//  Created by 정상윤 on 12/12/23.
//

import Foundation

final class PostNotificationPublisher {
    
    static let shared = PostNotificationPublisher()
    
    private let center: NotificationCenter
    
    init(center: NotificationCenter = .default) {
        self.center = center
    }
    
    func publishPostCreated(isRequest: Bool) {
        let info = ["type": PostType(isRequest: isRequest)]
        center.post(name: .postCreated, object: nil, userInfo: info)
    }
    
    func publishPostEdited(postID: Int) {
        let info = ["postID": postID]
        NotificationCenter.default.post(name: .postEdited, object: nil, userInfo: info)
    }
    
    func publishPostDeleted(postID: Int) {
        let info = ["postID": postID]
        NotificationCenter.default.post(name: .postDeleted, object: nil, userInfo: info)
    }
    
}
