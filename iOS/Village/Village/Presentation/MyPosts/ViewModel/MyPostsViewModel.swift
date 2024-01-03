//
//  MyPostsViewModel.swift
//  Village
//
//  Created by 조성민 on 12/5/23.
//

import Foundation
import Combine

final class MyPostsViewModel {
    
    var posts: [PostListItem] = []
    
    private var requestFilter: String = "0"
    
    private let nextPageUpdateOutput = PassthroughSubject<[PostListItem], Never>()
    private let refreshOutput = PassthroughSubject<[PostListItem], Never>()
    
    private var cancellableBag = Set<AnyCancellable>()
    
    init() {
        updateInitPosts()
    }
    
    func updateInitPosts() {
        let endpoint = APIEndPoints.getPosts(
            queryParameter: PostListRequestDTO(
                searchKeyword: nil,
                requestFilter: requestFilter,
                writer: JWTManager.shared.currentUserID,
                lastID: nil
            )
        )
        Task {
            do {
                guard let data = try await APIProvider.shared.request(with: endpoint) else { return }
                posts = data.map { $0.toDomain() }
                refreshOutput.send(posts)
            } catch {
                dump(error)
            }
        }
    }
    
    func updateNextPosts() {
        guard let lastPostID = posts.last?.postID else { return }
        let endpoint = APIEndPoints.getPosts(
            queryParameter: PostListRequestDTO(
                searchKeyword: nil,
                requestFilter: requestFilter,
                writer: JWTManager.shared.currentUserID,
                lastID: String(lastPostID)
            )
        )
        Task {
            do {
                guard let data = try await APIProvider.shared.request(with: endpoint) else { return }
                if posts.last != data.last?.toDomain() {
                    let newPosts = data.map { $0.toDomain() }
                    posts.append(contentsOf: newPosts)
                    nextPageUpdateOutput.send(newPosts)
                }
            } catch {
                dump(error)
            }
        }
    }
    
    func transform(input: Input) -> Output {
        
        input.nextPageUpdateSubject
            .sink { [weak self] in
                self?.updateNextPosts()
            }
            .store(in: &cancellableBag)
        
        input.refreshSubject
            .sink { [weak self] isRequest in
                self?.requestFilter = isRequest ? "1" : "0"
                self?.updateInitPosts()
            }
            .store(in: &cancellableBag)
        
        return Output(
            nextPageUpdateOutput: nextPageUpdateOutput.eraseToAnyPublisher(),
            refreshOutput: refreshOutput.eraseToAnyPublisher()
        )
    }
    
    struct Input {
        
        let nextPageUpdateSubject: AnyPublisher<Void, Never>
        let refreshSubject: AnyPublisher<Bool, Never>
        
    }
    
    struct Output {
        
        let nextPageUpdateOutput: AnyPublisher<[PostListItem], Never>
        let refreshOutput: AnyPublisher<[PostListItem], Never>
        
    }
    
}
