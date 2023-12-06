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
    var isRequest: Bool = false {
        didSet {
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
                    posts = data
                    dump(posts)
                } catch {
                    dump(error)
                }
            }
        }
    }
    private var requestFilter: String {
        return isRequest ? "1" : "0"
    }
    private var nextPageUpdateOutput = PassthroughSubject<[PostListResponseDTO], Never>()
    
    private var cancellableBag = Set<AnyCancellable>()
    
    init() {
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
                posts = data
                dump(posts)
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
                posts = data
                nextPageUpdateOutput.send(posts)
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
        
        return Output(
            nextPageUpdateOutput: nextPageUpdateOutput.eraseToAnyPublisher()
        )
    }
    
    struct Input {
        
        var nextPageUpdateSubject: AnyPublisher<Void, Never>
        
    }
    
    struct Output {
        
        var nextPageUpdateOutput: AnyPublisher<[PostListResponseDTO], Never>
        
    }
    
}
