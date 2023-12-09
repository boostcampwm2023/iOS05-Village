//
//  MyHiddenPostsViewModel.swift
//  Village
//
//  Created by 조성민 on 12/9/23.
//

import Foundation
import Combine

final class MyHiddenPostsViewModel {
    
    var posts: [PostMuteResponseDTO] = []
    
    private var requestFilter: String = "0"
    
    private var toggleOutput = PassthroughSubject<[PostMuteResponseDTO], Never>()
    
    private var cancellableBag = Set<AnyCancellable>()
    
    func transform(input: Input) -> Output {
        
        input.toggleSubject
            .sink { [weak self] in
                self?.requestFilter = self?.requestFilter == "0" ? "1" : "0"
                self?.getMyHiddenPosts()
            }
            .store(in: &cancellableBag)
        
        return Output(
            toggleUpdateOutput: toggleOutput.eraseToAnyPublisher()
        )
    }
    
    init() {
        getMyHiddenPosts()
    }
    
    private func getMyHiddenPosts() {        
        let endpoint = APIEndPoints.getHiddenPosts(
            requestFilter: RequestFilterDTO(
                requestFilter: requestFilter
            )
        )
        Task {
            do {
                guard let data = try await APIProvider.shared.request(with: endpoint) else { return }
                posts = data
                toggleOutput.send(data)
            } catch {
                dump(error)
            }
        }
    }
    
}

extension MyHiddenPostsViewModel {
    
    struct Input {
        var toggleSubject: AnyPublisher<Void, Never>
    }
    
    struct Output {
        var toggleUpdateOutput: AnyPublisher<[PostMuteResponseDTO], Never>
    }
    
}
