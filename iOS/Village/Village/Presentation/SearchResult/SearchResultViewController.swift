//
//  SearchResultViewController.swift
//  Village
//
//  Created by 박동재 on 12/9/23.
//

import UIKit
import Combine

final class SearchResultViewController: UIViewController {
    
    typealias ViewModel = SearchResultViewModel
    
    private let viewModel = ViewModel()
    private var cancellableBag = Set<AnyCancellable>()
    
    private let postTitle: String
    
    init(title: String) {
        self.postTitle = title
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .primary500
        bindViewModel()
    }

}

extension SearchResultViewController {
    
    private func bindViewModel() {
        let input = ViewModel.Input(postTitle: Just(postTitle).eraseToAnyPublisher())
        let output = viewModel.transform(input: input)
        
        output.searchResultList.receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    dump(error)
                }
            } receiveValue: { postList in
                // TODO: 데이터 테이블 뷰? 컬렉션 뷰에 추가하기
            }
            .store(in: &cancellableBag)
    }
    
}
