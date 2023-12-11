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
    
    func transform(input: Input) -> Output {
        handleRefresh(input: input)
        handlePagination(input: input)
        
        return Output(
            postList: postList.eraseToAnyPublisher()
        )
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
                self.pagination(type: type)
            }
            .store(in: &cancellableBag)
    }
    
}

private extension HomeViewModel {
    
    func refresh(type: PostType) {
        if type == .rent {
            lastRentPostID = nil
        } else {
            lastRequestPostID = nil
        }
        
        Task {
            do {
                let data = try await getList(type: type)
                if let lastPostID = data.last?.postID {
                    switch type {
                    case .rent:
                        lastRentPostID = "\(lastPostID)"
                    case .request:
                        lastRequestPostID = "\(lastPostID)"
                    }
                }
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
                    if self.lastRentPostID != "\(lastID)" {
                        self.postList.send(data)
                    }
                    self.lastRentPostID = "\(lastID)"
                } else {
                    if self.lastRequestPostID != "\(lastID)" {
                        self.postList.send(data)
                    }
                    self.lastRequestPostID = "\(lastID)"
                }
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
        
        guard let data = try await APIProvider.shared.request(with: endpoint) else { return [] }
        return data
    }
    
}

extension HomeViewModel {
    
    struct Input {
        let refresh: AnyPublisher<PostType, Never>
        let pagination: AnyPublisher<PostType, Never>
    }
    
    struct Output {
        let postList: AnyPublisher<[PostListResponseDTO], Error>
    }
    
}
