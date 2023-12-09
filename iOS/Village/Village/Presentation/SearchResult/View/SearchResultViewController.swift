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
    private let togglePublisher = PassthroughSubject<Void, Never>()
    private var cancellableBag = Set<AnyCancellable>()
    
    private let postTitle: String
    
    init(title: String) {
        self.postTitle = title
        super.init(nibName: nil, bundle: nil)
    }
    
    private lazy var requestSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["대여", "요청"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        control.selectedSegmentIndex = 0
        control.selectedSegmentTintColor = .primary500
        
        return control
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
        bindViewModel()
    }

}

extension SearchResultViewController {
    
    private func setUI() {
        self.view.backgroundColor = .systemBackground
        self.view.addSubview(requestSegmentedControl)
        
        configureConstraints()
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            requestSegmentedControl.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            requestSegmentedControl.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            requestSegmentedControl.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10),
            requestSegmentedControl.heightAnchor.constraint(equalToConstant: 35)
        ])
    }
    
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
    
    @objc private func segmentedControlChanged() {
        togglePublisher.send()
    }
    
}
