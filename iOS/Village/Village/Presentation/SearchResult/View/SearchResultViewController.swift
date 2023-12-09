//
//  SearchResultViewController.swift
//  Village
//
//  Created by 박동재 on 12/9/23.
//

import UIKit
import Combine

final class SearchResultViewController: UIViewController {
    
    typealias SearchResultDataSource = UITableViewDiffableDataSource<Section, PostListResponseDTO>
    typealias ViewModel = SearchResultViewModel
    
    enum Section { case list }
    
    private var viewModel = ViewModel()
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
    
    private lazy var dataSource = SearchResultDataSource(
        tableView: listTableView) { [weak self] (tableView, indexPath, post) in
            dump(post)
            if post.isRequest {
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: SearchRequstTableViewCell.identifier,
                    for: indexPath) as? SearchRequstTableViewCell else {
                    return SearchRequstTableViewCell()
                }
                cell.configureData(post: post)
                cell.selectionStyle = .none
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: SearchRentTableViewCell.identifier,
                    for: indexPath) as? SearchRentTableViewCell else {
                    return SearchRentTableViewCell()
                }
                cell.configureData(post: post)
                cell.selectionStyle = .none
                return cell
            }
        }
    
    private lazy var listTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 100
        tableView.register(SearchRequstTableViewCell.self, forCellReuseIdentifier: SearchRequstTableViewCell.identifier)
        tableView.register(SearchRentTableViewCell.self, forCellReuseIdentifier: SearchRentTableViewCell.identifier)
        tableView.separatorStyle = .none
        
        return tableView
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
        self.navigationItem.title = "검색결과"
        self.view.backgroundColor = .systemBackground
        self.view.addSubview(requestSegmentedControl)
        self.view.addSubview(listTableView)
        
        configureConstraints()
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            requestSegmentedControl.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            requestSegmentedControl.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            requestSegmentedControl.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10),
            requestSegmentedControl.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        NSLayoutConstraint.activate([
            listTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            listTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            listTableView.topAnchor.constraint(equalTo: requestSegmentedControl.bottomAnchor, constant: 5),
            listTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 5)
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
            } receiveValue: { [weak self] postList in
                self?.generateData(list: postList)
            }
            .store(in: &cancellableBag)
    }
    
    private func generateData(list: [PostListResponseDTO]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PostListResponseDTO>()
        snapshot.appendSections([.list])
        snapshot.appendItems(list)
        dataSource.apply(snapshot)
    }
    
    @objc private func segmentedControlChanged() {
        togglePublisher.send()
    }
    
}
