//
//  BlockedUserViewController.swift
//  Village
//
//  Created by 박동재 on 2023/12/04.
//

import UIKit
import Combine

class BlockedUserViewController: UIViewController {
    
    typealias BlockedUserDataSource = UITableViewDiffableDataSource<Section, UserResponseDTO>
    
    private let data = [
        UserResponseDTO(nickname: "123", profileImageURL: "https://cdn-icons-png.flaticon.com/512/12719/12719172.png"),
        UserResponseDTO(nickname: "sad", profileImageURL: "https://cdn-icons-png.flaticon.com/512/12719/12719172.png"),
        UserResponseDTO(nickname: "fsd", profileImageURL: "https://cdn-icons-png.flaticon.com/512/12719/12719172.png"),
        UserResponseDTO(nickname: "asd", profileImageURL: ""),
        UserResponseDTO(nickname: "zcx", profileImageURL: "https://cdn-icons-png.flaticon.com/512/12719/12719172.png")
    ]
    
    enum Section {
        case user
    }
    
    private let reuseIdentifier = BlockedUserTableViewCell.identifier
    private var cancellableBag = Set<AnyCancellable>()
    
    private lazy var userTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 60
        tableView.register(BlockedUserTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.separatorStyle = .none
        
        return tableView
    }()
    
    private lazy var dataSource: BlockedUserDataSource = BlockedUserDataSource(
        tableView: userTableView,
        cellProvider: { [weak self] (tableView, indexPath, user) in
            guard let self = self else { return BlockedUserTableViewCell() }
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: self.reuseIdentifier,
                for: indexPath) as? BlockedUserTableViewCell else {
                return BlockedUserTableViewCell()
            }
            
            cell.configureData(user: user)
            cell.selectionStyle = .none
            return cell
        }
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
        generateData()
    }

}

extension BlockedUserViewController {
    
    private func setUI() {
        setNavigationUI()
        self.view.addSubview(userTableView)
        
        configureConstraints()
    }
    
    private func setNavigationUI() {
        self.navigationItem.title = "차단 관리"
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            userTableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20),
            userTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            userTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            userTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    private func generateData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, UserResponseDTO>()
        snapshot.appendSections([.user])
        snapshot.appendItems(data)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
}
