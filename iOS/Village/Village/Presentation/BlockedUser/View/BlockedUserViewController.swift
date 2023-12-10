//
//  BlockedUserViewController.swift
//  Village
//
//  Created by 박동재 on 2023/12/04.
//

import UIKit
import Combine

final class BlockedUserViewController: UIViewController {
    
    typealias BlockedUserDataSource = UITableViewDiffableDataSource<Section, UserResponseDTO>
    
    typealias ViewModel = BlockedUsersViewModel
    typealias Input = ViewModel.Input
    
    enum Section {
        case user
    }
    
    private let viewModel: ViewModel
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
        generateData()
    }

}

private extension BlockedUserViewController {
    
    func bindViewModel() {
        // viewmodel 과 바인딩 output, input 
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
    
    func generateData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, UserResponseDTO>()
        snapshot.appendSections([.user])
        
        // viewmodel에서 user 목록 가져오기
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
}
