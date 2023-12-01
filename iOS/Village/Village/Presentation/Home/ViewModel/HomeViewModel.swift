//
//  HomeViewModel.swift
//  Village
//
//  Created by 박동재 on 2023/11/16.
//

import Foundation
import Combine

final class HomeViewModel {
    
    private var cancellableBag = Set<AnyCancellable>()
    private var postList = PassthroughSubject<[PostListItem], Never>()
    
    func transform(input: Input) -> Output {
        input.currentPage
            .sink(receiveValue: { [weak self] page in
                self?.getPosts(page: page)
            })
            .store(in: &cancellableBag)
        
        return Output(postList: postList.eraseToAnyPublisher())
    }
    
    private func getPosts(page: Int) {
        let request = PostListRequestDTO(page: page)
        let endpoint = APIEndPoints.getPosts(with: request)
        
        Task {
            do {
                guard let data = try await APIProvider.shared.request(with: endpoint) else { return }
                postList.send(data.map { PostListItem(dto: $0) })
            } catch let error {
                dump(error)
            }
        }
    }
    
}

extension HomeViewModel {
    
    struct Input {
        var currentPage: CurrentValueSubject<Int, Never>
    }
    
    struct Output {
        var postList: AnyPublisher<[PostListItem], Never>
    }
    
}
