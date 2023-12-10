//
//  HomeViewModel.swift
//  Village
//
//  Created by 박동재 on 2023/11/16.
//

import Foundation
import Combine

final class HomeViewModel {
    
    typealias PostList = [PostListResponseDTO]
    
    private var cancellableBag = Set<AnyCancellable>()
    
    private let postList = PassthroughSubject<PostList, Error>()
    
    private var lastRentPostID: String?
    private var lastRequestPostID: String?
    
    private var isRentEnd = false
    private var isRequestEnd = false
    
    func transform(input: Input) -> Output {
        handleRefresh(input: input)
        handlePagination(input: input)
        
        return Output(postList: postList.eraseToAnyPublisher())
    }
    
    private func handleRefresh(input: Input) {
        input.refresh
            .sink { [weak self] type in
                self?.refresh(type: type)
            }
            .store(in: &cancellableBag)
    }
    
    private func handlePagination(input: Input) {
        input.pagination
            .sink { [weak self] type in
                guard let self = self else { return }
                
                if (type == .rent && !self.isRentEnd) || (type == .request && !self.isRequestEnd) {
                    self.pagination(type: type)
                }
            }
            .store(in: &cancellableBag)
    }
    
}

private extension HomeViewModel {
    
    func refresh(type: PostType) {
        if type == .rent {
            isRentEnd = false
            lastRentPostID = nil
        } else {
            isRequestEnd = false
            lastRequestPostID = nil
        }
        
        Task {
            do {
                let data = try await getList(type: type)
                postList.send(data)
            } catch {
                postList.send(completion: .failure(error))
            }
        }
    }
    
    func pagination(type: PostType) {
        Task {
            do {
                let data = try await self.getList(type: type)
                
                guard let lastID = data.last?.postID else { return }
                if type == .rent {
                    self.lastRentPostID = "\(lastID)"
                } else {
                    self.lastRequestPostID = "\(lastID)"
                }
                
                self.postList.send(data)
            } catch {
                self.postList.send(completion: .failure(error))
            }
        }
    }
    
    func getList(type: PostType) async throws -> PostList {
        let filter: String
        let lastPostID: String?
        
        switch type {
        case .rent:
            filter = "0"
            lastPostID = lastRentPostID
        case .request:
            filter = "1"
            lastPostID = lastRequestPostID
        }
        
        let endpoint = APIEndPoints.getPosts(queryParameter: PostListRequestDTO(requestFilter: filter,
                                                                                page: lastPostID))
        
        guard let data = try await APIProvider.shared.request(with: endpoint) else {
            if type == .rent {
                isRentEnd = true
            } else {
                isRequestEnd = true
            }
            return []
        }
        return data
    }
    
}

extension HomeViewModel {
    
    struct Input {
        var refresh: AnyPublisher<PostType, Never>
        var pagination: AnyPublisher<PostType, Never>
    }
    
    struct Output {
        var postList: AnyPublisher<[PostListResponseDTO], Error>
    }
    
}
