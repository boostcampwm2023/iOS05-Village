//
//  SearchResultViewModel.swift
//  Village
//
//  Created by 박동재 on 12/9/23.
//

import Foundation
import Combine

final class SearchResultViewModel {
    
    private var cancellableBag = Set<AnyCancellable>()
    private var searchResultList = PassthroughSubject<[PostListItem], NetworkError>()
    
    func transform(input: Input) -> Output {
        input.postTitle
            .sink { [weak self] title in
                self?.getList(title: title)
            }
            .store(in: &cancellableBag)
        
        return Output(searchResultList: searchResultList.eraseToAnyPublisher())
    }
    
    private func getList(title: String) {
        let request = PostListRequestDTO(searchKeyword: title)
        let endpoint = APIEndPoints.getPosts(queryParameter: request)

        Task {
            do {
                guard let data = try await APIProvider.shared.request(with: endpoint) else { return }
            } catch {
                dump(error)
            }
        }
    }
    
}

extension SearchResultViewModel {
    
    struct Input {
        var postTitle: AnyPublisher<String, Never>
    }
    
    struct Output {
        var searchResultList: AnyPublisher<[PostListItem], NetworkError>
    }
    
}
