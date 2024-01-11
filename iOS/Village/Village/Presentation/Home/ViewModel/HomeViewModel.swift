//
//  HomeViewModel.swift
//  Village
//
//  Created by 박동재 on 2023/11/16.
//

import Foundation
import Combine

final class HomeViewModel {
    
    typealias Post = PostListItem
    typealias PagingInfo = (isLastPage: Bool, lastID: String?)
    
    private var cancellableBag = Set<AnyCancellable>()
    
    private let postList = PassthroughSubject<[Post], Error>()
    private let createdPost = PassthroughSubject<PostType, Never>()
    private let deletedPost = PassthroughSubject<Int, Never>()
    private let editedPost = PassthroughSubject<Post, Never>()
    private let hiddenChanged = PassthroughSubject<Void, Never>()
    
    private var rentPagingInfo: PagingInfo = (false, nil)
    private var requestPagingInfo: PagingInfo = (false, nil)
    
    func transform(input: Input) -> Output {
        handleRefresh(input: input)
        handlePagination(input: input)
        
        return Output(
            postList: postList.eraseToAnyPublisher(),
            createdPost: createdPost.eraseToAnyPublisher(),
            deletedPost: deletedPost.eraseToAnyPublisher(),
            editedPost: editedPost.eraseToAnyPublisher(),
            hiddenChanged: hiddenChanged.eraseToAnyPublisher()
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
                let pagingInfo = (type == .rent) ? rentPagingInfo : requestPagingInfo
                if !pagingInfo.isLastPage {
                    self.getList(type: type)
                }
            }
            .store(in: &cancellableBag)
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handlePostEdited(notification:)),
                                               name: .postEdited,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handlePostCreated(notification:)),
                                               name: .postCreated,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handlePostDeleted(notification:)),
                                               name: .postDeleted,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleHiddenChanged),
                                               name: .postRefreshAll,
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
                let editedItem = PostListItem(
                    title: post.title,
                    price: post.price,
                    postID: post.postID,
                    userID: post.userID,
                    thumbnailURL: post.images.first,
                    isRequest: post.isRequest,
                    startDate: post.startDate,
                    endDate: post.endDate
                )
                editedPost.send(editedItem)
            } catch {
                dump(error)
            }
        }
    }
    
    func handlePostCreated(notification: Notification) {
        guard let postType = notification.userInfo?["type"] as? PostType else { return }
        
        createdPost.send(postType)
    }
    
    func handlePostDeleted(notification: Notification) {
        guard let postID = notification.userInfo?["postID"] as? Int else { return }
        
        deletedPost.send(postID)
    }
    
    func handleHiddenChanged() {
        hiddenChanged.send()
    }
    
}

private extension HomeViewModel {
    
    func refresh(type: PostType) {
        if type == .rent {
            rentPagingInfo = (false, nil)
        } else {
            requestPagingInfo = (false, nil)
        }
        
        getList(type: type)
    }
    
    func getList(type: PostType) {
        let lastPostID = (type == .rent) ? rentPagingInfo.lastID : requestPagingInfo.lastID
        let requestValue = PostListUseCase.RequestValue(
            postType: type,
            lastID: lastPostID
        )
        
        PostListUseCase(
            repository: DefaultPostListRepository(),
            requestValue: requestValue
        )
        .start()
        .sink { completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                dump(error)
            }
        } receiveValue: { [weak self] list in
            self?.checkLastPage(type: type, list: list)
            self?.postList.send(list)
        }
        .store(in: &cancellableBag)

    }
    
    func checkLastPage(type: PostType, list: [PostListItem]) {
        let pagingInfo: PagingInfo
        
        if let lastID = list.last?.postID {
            pagingInfo = (false, "\(lastID)")
        } else {
            pagingInfo = (true, nil)
        }
        
        if type == .rent {
            rentPagingInfo = pagingInfo
        } else {
            requestPagingInfo = pagingInfo
        }
    }
    
}

extension HomeViewModel {
    
    struct Input {
        let refresh: AnyPublisher<PostType, Never>
        let pagination: AnyPublisher<PostType, Never>
    }
    
    struct Output {
        let postList: AnyPublisher<[Post], Error>
        let createdPost: AnyPublisher<PostType, Never>
        let deletedPost: AnyPublisher<Int, Never>
        let editedPost: AnyPublisher<Post, Never>
        let hiddenChanged: AnyPublisher<Void, Never>
    }
    
}
