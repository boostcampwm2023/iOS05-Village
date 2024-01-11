//
//  ReportUseCase.swift
//  Village
//
//  Created by 조성민 on 12/22/23.
//

import Foundation
import Combine

struct ReportUseCase: UseCase {
    
    typealias ResultValue = Void
    
    struct RequestValue {
        let postID: Int
        let userID: String
        let description: String
    }
    
    private let repository: DefaultReportRepository
    private let requestValue: RequestValue
    
    init(
        repository: DefaultReportRepository,
        requestValue: RequestValue
    ) {
        self.repository = repository
        self.requestValue = requestValue
    }
    
    func start() -> AnyPublisher<ResultValue, NetworkError> {
        repository.reportUser(
            postID: requestValue.postID,
            userID: requestValue.userID,
            description: requestValue.description
        )
        .eraseToAnyPublisher()
    }
    
}
