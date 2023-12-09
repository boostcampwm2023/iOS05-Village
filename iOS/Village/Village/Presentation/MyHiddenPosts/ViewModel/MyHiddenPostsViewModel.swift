//
//  MyHiddenPostsViewModel.swift
//  Village
//
//  Created by 조성민 on 12/9/23.
//

import Foundation
import Combine

struct HidePostInfo {
    
    let postID: Int
    let bool: Bool
    
}

final class MyHiddenPostsViewModel {
    
    var posts: [PostMuteResponseDTO] = []
    
    private var requestFilter: String = "0"
    
    private var toggleOutput = PassthroughSubject<[PostMuteResponseDTO], Never>()
    
    private var cancellableBag = Set<AnyCancellable>()
    
    func transform(input: Input) -> Output {
        
        input.toggleSubject
            .sink { [weak self] in
                self?.requestFilter = self?.requestFilter == "0" ? "1" : "0"
                self?.getMyHiddenPosts()
            }
            .store(in: &cancellableBag)
        
        input.toggleHideSubject
            .sink { [weak self] hideInfo in
                self?.toggleHide(hideInfo: hideInfo)
            }
            .store(in: &cancellableBag)
        
        return Output(
            toggleUpdateOutput: toggleOutput.eraseToAnyPublisher()
        )
    }
    
    init() {
        getMyHiddenPosts()
    }
    
    private func getMyHiddenPosts() {        
        let endpoint = APIEndPoints.getHiddenPosts(
            requestFilter: RequestFilterDTO(
                requestFilter: requestFilter
            )
        )
        Task {
            do {
                guard let data = try await APIProvider.shared.request(with: endpoint) else { return }
                posts = data
                toggleOutput.send(data)
            } catch {
                dump(error)
            }
        }
    }
    
    private func toggleHide(hideInfo: HidePostInfo) {
        let endpoint = hideInfo.bool ?
        APIEndPoints.hidePost(postID: hideInfo.postID) :
        APIEndPoints.unhidePost(postID: hideInfo.postID)
        
        Task {
            do {
                try await APIProvider.shared.request(with: endpoint)
            } catch {
                dump(error)
            }
        }
        
    }
    
}

extension MyHiddenPostsViewModel {
    
    struct Input {
        let toggleSubject: AnyPublisher<Void, Never>
        let toggleHideSubject: AnyPublisher<HidePostInfo, Never>
    }
    
    struct Output {
        let toggleUpdateOutput: AnyPublisher<[PostMuteResponseDTO], Never>
    }
    
}
