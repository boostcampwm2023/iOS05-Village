//
//  MyPostsViewController.swift
//  Village
//
//  Created by 조성민 on 12/5/23.
//

import UIKit
import Combine

final class MyPostsViewController: UIViewController {
    
    typealias MyPostsDataSource = UITableViewDiffableDataSource<Section, PostListResponseDTO>
    
    typealias ViewModel = MyPostsViewModel
    typealias Input = ViewModel.Input
    
    enum Section {
        case posts
    }
    
    private let viewModel: ViewModel
    
    private lazy var dataSource: MyPostsDataSource = MyPostsDataSource(
        tableView: tableView) { [weak self] (tableView, indexPath, post) in
            if post.isRequest {
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: RequestPostTableViewCell.identifier,
                    for: indexPath) as? RequestPostTableViewCell else {
                    return RequestPostTableViewCell()
                }
                cell.configureData(post: post)
                cell.selectionStyle = .none
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: RentPostTableViewCell.identifier,
                    for: indexPath) as? RentPostTableViewCell else {
                    return RentPostTableViewCell()
                }
                cell.configureData(post: post)
                cell.selectionStyle = .none
                return cell
            }
        }
    
    private lazy var requestSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["대여글", "요청글"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        control.selectedSegmentIndex = 0
        control.selectedSegmentTintColor = .primary500
        
        return control
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 100
        tableView.register(RequestPostTableViewCell.self, forCellReuseIdentifier: RequestPostTableViewCell.identifier)
        tableView.register(RentPostTableViewCell.self, forCellReuseIdentifier: RentPostTableViewCell.identifier)
        tableView.separatorStyle = .none
        tableView.delegate = self
        
        return tableView
    }()
    
    private let paginationPublisher = PassthroughSubject<Void, Never>()
    private let togglePublisher = PassthroughSubject<Void, Never>()
    private var cancellableBag = Set<AnyCancellable>()
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        setUI()
        generateData()
    }
    
    @objc private func segmentedControlChanged() {
        togglePublisher.send()
    }
    
}

private extension MyPostsViewController {
    
    func bindViewModel() {
        let output = viewModel.transform(input: MyPostsViewModel.Input(
            nextPageUpdateSubject: paginationPublisher.eraseToAnyPublisher(),
            toggleSubject: togglePublisher.eraseToAnyPublisher()
        ))
        
        output.nextPageUpdateOutput
            .receive(on: DispatchQueue.main)
            .sink { [weak self] posts in
                self?.addNextPage(posts: posts)
            }
            .store(in: &cancellableBag)
        
        output.toggleUpdateOutput
            .receive(on: DispatchQueue.main)
            .sink { [weak self] posts in
                self?.toggleData(posts: posts)
            }
            .store(in: &cancellableBag)
    }
    
    func addNextPage(posts: [PostListResponseDTO]) {
        var snapshot = dataSource.snapshot()
        snapshot.appendItems(posts)
        dataSource.apply(snapshot)
    }
    
    func setUI() {
        setNavigationUI()
        
        view.addSubview(requestSegmentedControl)
        view.addSubview(tableView)
        
        view.backgroundColor = .systemBackground
        configureConstraints()
    }
    
    func generateData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PostListResponseDTO>()
        snapshot.appendSections([.posts])
        snapshot.appendItems(viewModel.posts)
        dataSource.apply(snapshot)
    }
    
    func toggleData(posts: [PostListResponseDTO]) {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([.posts])
        snapshot.appendItems(posts)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func setNavigationUI() {
        navigationItem.title = "내 게시글"
    }
    
    func configureConstraints() {
        
        NSLayoutConstraint.activate([
            requestSegmentedControl.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10
            ),
            requestSegmentedControl.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10
            ),
            requestSegmentedControl.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10
            ),
            requestSegmentedControl.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor
            ),
            tableView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor
            ),
            tableView.topAnchor.constraint(
                equalTo: requestSegmentedControl.bottomAnchor, constant: 5
            ),
            tableView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 5
            )
        ])
        
    }
    
}

extension MyPostsViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y
        let tableViewContentSizeY = self.tableView.contentSize.height
        let paginationY = tableViewContentSizeY * 0.3
        if contentOffsetY > tableViewContentSizeY - paginationY {
            paginationPublisher.send()
        }
    }
    
}
