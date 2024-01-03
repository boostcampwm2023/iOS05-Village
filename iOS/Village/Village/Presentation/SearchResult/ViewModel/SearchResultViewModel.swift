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
    private let searchResultList = PassthroughSubject<[PostListItem], NetworkError>()
    private var postTitle: String = ""
    private var lastPostID: String = ""
    
    enum Filter: String {
        case request = "0"
        case rent = "1"
    }
    
    private var searchFilter = Filter.request
    
    func transform(input: Input) -> Output {
        input.postTitle
            .sink { [weak self] title in
                self?.postTitle = title
                self?.getList()
            }
            .store(in: &cancellableBag)
        
        input.toggleSubject
            .sink { [weak self] in
                self?.searchFilter = self?.searchFilter == .request ? .rent : .request
                self?.getList()
            }
            .store(in: &cancellableBag)
        
        input.scrollEvent
            .sink { [weak self] in
                self?.getAddedList()
            }
            .store(in: &cancellableBag)
        
        return Output(searchResultList: searchResultList.eraseToAnyPublisher())
    }
    
    private func getList() {
        let request = PostListRequestDTO(
            searchKeyword: self.postTitle,
            requestFilter: searchFilter.rawValue
            )
        let endpoint = APIEndPoints.getPosts(queryParameter: request)

        Task {
            do {
                guard let data = try await APIProvider.shared.request(with: endpoint),
                      let lastID = data.last?.postID
                else { return }
                searchResultList.send(data.map { $0.toDomain() })
                self.lastPostID = "\(lastID)"
            } catch {
                dump(error)
            }
        }
    }
    
    private func getAddedList() {
        let request = PostListRequestDTO(
            searchKeyword: self.postTitle,
            requestFilter: self.searchFilter.rawValue,
            lastID: self.lastPostID
        )
        let endpoint = APIEndPoints.getPosts(queryParameter: request)
        
        Task {
            do {
                guard let data = try await APIProvider.shared.request(with: endpoint),
                      let lastID = data.last?.postID
                else {
                    searchResultList.send([])
                    return
                }
                searchResultList.send(data.map { $0.toDomain() })
                self.lastPostID = "\(lastID)"
            } catch {
                searchResultList.send(completion: .failure(NetworkError.urlRequestError))
            }
        }
    }
    
}

extension SearchResultViewModel {
    
    struct Input {
        let postTitle: AnyPublisher<String, Never>
        let toggleSubject: AnyPublisher<Void, Never>
        let scrollEvent: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let searchResultList: AnyPublisher<[PostListItem], NetworkError>
    }
    
}
