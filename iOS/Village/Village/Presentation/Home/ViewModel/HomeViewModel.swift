//
//  HomeViewModel.swift
//  Village
//
//  Created by 박동재 on 2023/11/16.
//

import Foundation
import Combine

final class HomeViewModel {
    
    typealias Post = PostResponseDTO
    
    private var cancellableBag = Set<AnyCancellable>()
    
    private let postList = PassthroughSubject<[Post], Error>()
    private let createdPost = PassthroughSubject<Void, Never>()
    private let deletedPost = PassthroughSubject<Int, Never>()
    private let editedPost = PassthroughSubject<Post, Never>()
    
    private var lastRentPostID: String?
    private var lastRequestPostID: String?
    
    func transform(input: Input) -> Output {
        handleRefresh(input: input)
        handlePagination(input: input)
        
        return Output(
            postList: postList.eraseToAnyPublisher(),
            createdPost: createdPost.eraseToAnyPublisher(),
            deletedPost: deletedPost.eraseToAnyPublisher(),
            editedPost: editedPost.eraseToAnyPublisher()
        )
    }
    
    init() {
        addObserver()
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
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handlePostEdited(notification:)),
                                               name: .postEdited,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handlePostCreated),
                                               name: .postCreated,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handlePostDeleted(notification:)),
                                               name: .postDeleted,
                                               object: nil)
    }
    
}

@objc
private extension HomeViewModel {
    
    func handlePostEdited(notification: Notification) {
        guard let postID = notification.userInfo?["postID"] as? Int else { return }
        
        let endpoint = APIEndPoints.getPost(id: postID)
        
        Task {
            do {
                guard let post = try await APIProvider.shared.request(with: endpoint) else { return }
                editedPost.send(post)
            } catch {
                dump(error)
            }
        }
    }
    
    func handlePostCreated() {
        createdPost.send()
    }
    
    func handlePostDeleted(notification: Notification) {
        guard let postID = notification.userInfo?["postID"] as? Int else { return }
        
        deletedPost.send(postID)
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
    
    func getList(type: PostType) async throws -> [Post] {
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
        let postList: AnyPublisher<[Post], Error>
        let createdPost: AnyPublisher<Void, Never>
        let deletedPost: AnyPublisher<Int, Never>
        let editedPost: AnyPublisher<Post, Never>
    }
    
}
