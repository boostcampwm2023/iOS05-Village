//
//  DefaultReportRepository.swift
//  Village
//
//  Created by 조성민 on 12/22/23.
//

import Foundation
import Combine

struct DefaultReportRepository: ReportRepository {
    
    private func makeReportUserEndpoint(
        postID: Int,
        userID: String,
        description: String
    ) -> EndPoint<Void> {
        let reportDTO = ReportDTO(
            postID: postID,
            userID: userID,
            description: description
        )
        
        return EndPoint(
            baseURL: Constant.baseURL,
            path: "report",
            method: .POST,
            bodyParameters: reportDTO,
            headers: ["Content-Type": "application/json"]
        )
    }
    
    func reportUser(
        postID: Int,
        userID: String,
        description: String
    ) -> AnyPublisher<Void, NetworkError> {
        let endpoint = makeReportUserEndpoint(
            postID: postID,
            userID: userID,
            description: description
        )
        
        return NetworkService.shared.request(endpoint)
    }
    
}
