//
//  ReportUseCase.swift
//  Village
//
//  Created by 조성민 on 12/22/23.
//

import Foundation
import Combine

struct ReportUseCase {
    
    struct RequestValue {
        let postID: Int
        let userID: String
        let description: String
    }
    
    private let repository: DefaultReportRepository
    private let requestValue: RequestValue
    private let completeOutput: PassthroughSubject<Void, Error>
    
    init(
        repository: DefaultReportRepository,
        requestValue: RequestValue,
        completeOutput: PassthroughSubject<Void, Error>
    ) {
        self.repository = repository
        self.requestValue = requestValue
        self.completeOutput = completeOutput
    }
    
    func start() {
        Task {
            let result = await self.repository.reportUser(
                postID: requestValue.postID,
                userID: requestValue.userID,
                description: requestValue.description
            )
            switch result {
            case .success(let success):
                completeOutput.send()
            case .failure(let error):
                completeOutput.send(completion: .failure(error))
            }
        }
    }
    
}
