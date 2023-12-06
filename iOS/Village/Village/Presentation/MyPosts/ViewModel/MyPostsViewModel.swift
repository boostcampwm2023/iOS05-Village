//
//  MyPostsViewModel.swift
//  Village
//
//  Created by 조성민 on 12/5/23.
//

import Foundation
import Combine

final class MyPostsViewModel {
    
    var posts: [PostListResponseDTO] = []
    
    private var requestFilter: String = "0"
    
    private var nextPageUpdateOutput = PassthroughSubject<[PostListResponseDTO], Never>()
    private var toggleOutput = PassthroughSubject<[PostListResponseDTO], Never>()
    
    private var cancellableBag = Set<AnyCancellable>()
    
    init() {
        updateInitPosts()
    }
    
    func updateInitPosts() {
        let endpoint = APIEndPoints.getPosts(
            queryParameter: GetPostsQueryDTO(
                searchKeyword: nil,
                requestFilter: requestFilter,
                writer: JWTManager.shared.currentUserID,
                page: nil
            )
        )
        Task {
            do {
                guard let data = try await APIProvider.shared.request(with: endpoint) else { return }
                if posts != data {
                    posts = data
                    toggleOutput.send(data)
                }
            } catch {
                dump(error)
            }
        }
    }
    
    func updateNextPosts() {
        guard let lastPostID = posts.last?.postID else { return }
        let endpoint = APIEndPoints.getPosts(
            queryParameter: GetPostsQueryDTO(
                searchKeyword: nil,
                requestFilter: requestFilter,
                writer: JWTManager.shared.currentUserID,
                page: String(lastPostID)
            )
        )
        Task {
            do {
                guard let data = try await APIProvider.shared.request(with: endpoint) else { return }
                if posts != data {
                    posts = data
                    nextPageUpdateOutput.send(data)
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
        
        input.toggleSubject
            .sink { [weak self] in
                self?.requestFilter = self?.requestFilter == "0" ? "1" : "0"
                self?.updateInitPosts()
            }
            .store(in: &cancellableBag)
        
        return Output(
            nextPageUpdateOutput: nextPageUpdateOutput.eraseToAnyPublisher(),
            toggleUpdateOutput: toggleOutput.eraseToAnyPublisher()
        )
    }
    
    struct Input {
        
        var nextPageUpdateSubject: AnyPublisher<Void, Never>
        var toggleSubject: AnyPublisher<Void, Never>
        
    }
    
    struct Output {
        
        var nextPageUpdateOutput: AnyPublisher<[PostListResponseDTO], Never>
        var toggleUpdateOutput: AnyPublisher<[PostListResponseDTO], Never>
        
    }
    
}
