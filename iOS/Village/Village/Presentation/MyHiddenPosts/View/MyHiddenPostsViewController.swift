//
//  MyHiddenPostsViewController.swift
//  Village
//
//  Created by 조성민 on 12/9/23.
//

import UIKit
import Combine

final class MyHiddenPostsViewController: UIViewController {
    
    typealias MyHiddenPostsDataSource = UITableViewDiffableDataSource<Section, PostMuteResponseDTO>
    
    typealias ViewModel = MyHiddenPostsViewModel
    typealias Input = ViewModel.Input
    
    enum Section {
        case posts
    }
    
    private let viewModel: ViewModel
    
    private lazy var dataSource: MyHiddenPostsDataSource = MyHiddenPostsDataSource(
        tableView: tableView) { [weak self] (tableView, indexPath, post) in
            
            if post.isRequest {
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: HiddenRequestPostTableViewCell.identifier,
                    for: indexPath) as? HiddenRequestPostTableViewCell,
                      let self = self else {
                    return HiddenRequestPostTableViewCell()
                }
                cell.configureData(post: post)
                cell.selectionStyle = .none
                cell.hideToggleSubject
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] isHidden in
                        self?.hideTogglePublisher.send(HidePostInfo(
                            postID: post.postID, isHidden: isHidden)
                        )
                    }
                    .store(in: &self.cancellableBag)
                
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: HiddenRentPostTableViewCell.identifier,
                    for: indexPath) as? HiddenRentPostTableViewCell,
                      let self = self else {
                    return HiddenRentPostTableViewCell()
                }
                cell.configureData(post: post)
                cell.selectionStyle = .none
                cell.hideToggleSubject
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] isHidden in
                        self?.hideTogglePublisher.send(HidePostInfo(
                            postID: post.postID, isHidden: isHidden)
                        )
                    }
                    .store(in: &self.cancellableBag)
                
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
        tableView.register(
            HiddenRentPostTableViewCell.self,
            forCellReuseIdentifier: HiddenRentPostTableViewCell.identifier
        )
        tableView.register(
            HiddenRequestPostTableViewCell.self,
            forCellReuseIdentifier: HiddenRequestPostTableViewCell.identifier
        )
        tableView.separatorStyle = .none
        
        return tableView
    }()
    
    private let togglePublisher = PassthroughSubject<Void, Never>()
    private let hideTogglePublisher = PassthroughSubject<HidePostInfo, Never>()
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
        setNavigationUI()
        setUI()
        generateData()
    }
    
    @objc private func segmentedControlChanged() {
        togglePublisher.send()
    }
    
}

private extension MyHiddenPostsViewController {
    
    func bindViewModel() {
        let output = viewModel.transform(input: MyHiddenPostsViewModel.Input(
            toggleSubject: togglePublisher.eraseToAnyPublisher(),
            toggleHideSubject: hideTogglePublisher.eraseToAnyPublisher()
        ))
        
        output.toggleUpdateOutput
            .receive(on: DispatchQueue.main)
            .sink { [weak self] posts in
                self?.toggleData(posts: posts)
            }
            .store(in: &cancellableBag)
        
    }
    
    func setUI() {
        view.addSubview(requestSegmentedControl)
        view.addSubview(tableView)
        
        view.backgroundColor = .systemBackground
        configureConstraints()
    }
    
    func generateData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PostMuteResponseDTO>()
        snapshot.appendSections([.posts])
        snapshot.appendItems(viewModel.posts)
        dataSource.apply(snapshot)
    }
    
    func toggleData(posts: [PostMuteResponseDTO]) {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([.posts])
        snapshot.appendItems(posts)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func setNavigationUI() {
        navigationItem.title = "숨긴 게시글"
        navigationItem.backButtonDisplayMode = .minimal
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
