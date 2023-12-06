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
    
    private var postList = PassthroughSubject<[PostListItem], Error>()
    private var lastPostID: String?
    private var isPaging = false
    
    func transform(input: Input) -> Output {
        input.needPostList
            .sink(receiveValue: { [weak self] isRefresh in
                guard let self = self else { return }
                if !self.isPaging {
                    self.getPosts(isRefresh: isRefresh)
                }
            })
            .store(in: &cancellableBag)
        
        return Output(postList: postList.eraseToAnyPublisher())
    }
    
    private func getPosts(isRefresh: Bool) {
        if isRefresh { lastPostID = nil }
        
        let postRequestDTO = (lastPostID == nil) ? nil : PostListRequestDTO(page: lastPostID)
        let endpoint = APIEndPoints.getPosts(queryParameter: postRequestDTO)
        
        Task {
            do {
                isPaging = true
                guard let items = try await APIProvider.shared.request(with: endpoint),
                      let lastID = items.last?.postID else { return }
                lastPostID = "\(lastID)"
                postList.send(items.map { PostListItem(dto: $0) })
                isPaging = false
            } catch {
                postList.send(completion: .failure(error))
                isPaging = false
            }
        }
    }
    
}

extension HomeViewModel {
    
    struct Input {
        var needPostList: AnyPublisher<Bool, Never>
    }
    
    struct Output {
        var postList: AnyPublisher<[PostListItem], Error>
    }
    
}
