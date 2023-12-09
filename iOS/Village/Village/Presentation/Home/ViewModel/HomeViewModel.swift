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
    private var isLoading = false
    private let lock = NSLock()
    
    func transform(input: Input) -> Output {
        input.needPostList
            .sink(receiveValue: { [weak self] isRefresh in
                guard let self = self,
                      isLoading == false else { return }
                self.getPosts(isRefresh: isRefresh)
            })
            .store(in: &cancellableBag)
        
        return Output(postList: postList.eraseToAnyPublisher())
    }
    
    private func getPosts(isRefresh: Bool) {
        lock.withLock {
            if isRefresh { lastPostID = nil }
            
            let postRequestDTO = (lastPostID == nil) ? nil : PostListRequestDTO(page: lastPostID)
            let endpoint = APIEndPoints.getPosts(queryParameter: postRequestDTO)
            
            Task {
                do {
                    isLoading = true
                    guard let items = try await APIProvider.shared.request(with: endpoint),
                          let lastID = items.last?.postID else {
                        isLoading = false
                        return
                    }
                    lastPostID = "\(lastID)"
                    postList.send(items.map { PostListItem(dto: $0) })
                } catch {
                    postList.send(completion: .failure(error))
                }
                isLoading = false
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
