//
//  BlockedUserViewController.swift
//  Village
//
//  Created by 박동재 on 2023/12/04.
//

import UIKit
import Combine

final class BlockedUserViewController: UIViewController {
    
    typealias BlockedUserDataSource = UITableViewDiffableDataSource<Section, BlockedUserDTO>
    
    typealias ViewModel = BlockedUsersViewModel
    typealias Input = ViewModel.Input
    
    enum Section {
        case user
    }
    
    private let viewModel: ViewModel
    
    private let blockedToggleSubject = PassthroughSubject<BlockUserInfo, Never>()
    private var cancellableBag = Set<AnyCancellable>()
    
    private lazy var userTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 60
        tableView.register(BlockedUserTableViewCell.self, forCellReuseIdentifier: BlockedUserTableViewCell.identifier)
        tableView.separatorStyle = .none
        
        return tableView
    }()
    
    private lazy var dataSource: BlockedUserDataSource = BlockedUserDataSource(
        tableView: userTableView,
        cellProvider: { [weak self] (tableView, indexPath, user) in
            guard let self = self else { return BlockedUserTableViewCell() }
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: BlockedUserTableViewCell.identifier,
                for: indexPath) as? BlockedUserTableViewCell else {
                return BlockedUserTableViewCell()
            }
            cell.configureData(user: user)
            cell.selectionStyle = .none
            cell.blockToggleSubject
                .receive(on: DispatchQueue.main)
                .sink { [weak self] isBlocked in
                    self?.blockedToggleSubject.send(
                        BlockUserInfo(
                            userID: user.userID,
                            isBlocked: isBlocked)
                        )
                }
                .store(in: &cancellableBag)
            
            return cell
        }
    )
    
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
        configureConstraints()
    }

}

private extension BlockedUserViewController {
    
    func bindViewModel() {
        let output = viewModel.transform(
            input: BlockedUsersViewModel.Input(
                blockedToggleInput: blockedToggleSubject.eraseToAnyPublisher()
            )
        )
        output.blockedUsersOutput
            .receive(on: DispatchQueue.main)
            .sink { [weak self] users in
                self?.generateData(users: users)
            }
            .store(in: &cancellableBag)
        
    }
    
    func setUI() {
        self.view.addSubview(userTableView)
    }
    
    func setNavigationUI() {
        self.navigationItem.title = "차단 관리"
        self.navigationItem.backButtonDisplayMode = .minimal
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            userTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            userTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            userTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            userTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func generateData(users: [BlockedUserDTO]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, BlockedUserDTO>()
        snapshot.appendSections([.user])
        snapshot.appendItems(users)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
}
