//
//  ChatListViewController.swift
//  Village
//
//  Created by 박동재 on 2023/11/23.
//

import UIKit
import Combine

class ChatListViewController: UIViewController {
    
    typealias ChatListDataSource = UITableViewDiffableDataSource<Section, ChatListResponseDTO>
    typealias ViewModel = ChatListViewModel
    typealias Input = ViewModel.Input
    
    private let reuseIdentifier = ChatListTableViewCell.identifier
    private lazy var dataSource: ChatListDataSource = ChatListDataSource(
        tableView: chatListTableView,
        cellProvider: { [weak self] (tableView, indexPath, chatList) in
            guard let self = self else { return ChatListTableViewCell() }
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: self.reuseIdentifier,
                for: indexPath) as? ChatListTableViewCell else {
                return ChatListTableViewCell()
            }
            Task {
                do {
                    await cell.configureData(data: chatList)
                }
            }
            cell.selectionStyle = .none
            
            return cell
        }
    )
    
    private var currentPage = CurrentValueSubject<Int, Never>(1)
    private var viewModel = ViewModel()
    
    enum Section {
        case chat
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setViewModel()
        setUI()
        generateData()
    }
    
    private func setUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(chatListTableView)
        setNavigationUI()
        configureConstraints()
    }
    
    private func setViewModel() {
//        MARK: 더미데이터를 위한 코드 채팅API 구현 후, 삭제 예정
        guard let path = Bundle.main.path(forResource: "ChatList", ofType: "json") else { return }

        guard let jsonString = try? String(contentsOfFile: path) else { return }
        do {
            let decoder = JSONDecoder()
            let data = jsonString.data(using: .utf8)
            
            guard let data = data else { return }
            let list = try decoder.decode([ChatListResponseDTO].self, from: data)
            viewModel.updateTest(list: list)
        } catch {
            return
        }
    }

    private func setNavigationUI() {
        let titleLabel = UILabel()
        titleLabel.setTitle("채팅")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        self.navigationItem.backButtonDisplayMode = .minimal
    }
    
    private lazy var chatListTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 80
        tableView.register(ChatListTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.separatorStyle = .none
        tableView.delegate = self
        
        return tableView
    }()
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            chatListTableView.topAnchor.constraint(equalTo: view.topAnchor),
            chatListTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatListTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatListTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func generateData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ChatListResponseDTO>()
        snapshot.appendSections([.chat])
        snapshot.appendItems(viewModel.getTest())
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension ChatListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("!@#")
        guard let chat = dataSource.itemIdentifier(for: indexPath) else { return }
        
        let chatRoomVC = ChatRoomViewController(roomID: 1)
        chatRoomVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(chatRoomVC, animated: true)
    }
    
}
