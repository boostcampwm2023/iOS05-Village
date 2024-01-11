//
//  ReportRepository.swift
//  Village
//
//  Created by 조성민 on 12/22/23.
//

import Foundation
import Combine

protocol ReportRepository {
    
    func reportUser(
        postID: Int,
        userID: String,
        description: String
    ) -> AnyPublisher<Void, NetworkError>
    
}
