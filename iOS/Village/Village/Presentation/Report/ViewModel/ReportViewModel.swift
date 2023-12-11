//
//  ReportViewModel.swift
//  Village
//
//  Created by 조성민 on 12/10/23.
//

import Foundation
import Combine

final class ReportViewModel {
    
    private let userID: String
    private let postID: Int
    
    private let completeOutput = PassthroughSubject<Void, Never>()
    
    private var cancellableBag = Set<AnyCancellable>()
    
    init(userID: String, postID: Int) {
        self.userID = userID
        self.postID = postID
    }
    
    func transform(input: Input) -> Output {
        
        input.reportButtonTapped
            .receive(on: DispatchQueue.main)
            .sink { [weak self] description in
                self?.report(description: description)
            }
            .store(in: &cancellableBag)
        return Output(
            completeOutput: completeOutput.eraseToAnyPublisher()
        )
    }
    
    private func report(description: String) {
        let endpoint = APIEndPoints.reportUser(
            reportInfo: ReportDTO(
                postID: postID, userID: userID, description: description
            )
        )
        
        Task {
            do {
                try await APIProvider.shared.request(with: endpoint)
                completeOutput.send()
            } catch {
                dump(error)
            }
        }
        
    }
    
}

extension ReportViewModel {
    
    struct Input {
        let reportButtonTapped: AnyPublisher<String, Never>
    }
    
    struct Output {
        let completeOutput: AnyPublisher<Void, Never>
    }
    
}
