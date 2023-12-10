//
//  ChatListViewController.swift
//  Village
//
//  Created by 박동재 on 2023/11/23.
//

import UIKit
import Combine

class ChatListViewController: UIViewController {
    
    typealias ChatListDataSource = UITableViewDiffableDataSource<Section, ChatListData>
    typealias ViewModel = ChatListViewModel
    private var getChatListSubject = CurrentValueSubject<Void, Never>(())
    private var cancellableBag = Set<AnyCancellable>()
    
    enum Section {
        case chat
    }
    
    private var viewModel = ViewModel()
    private let reuseIdentifier = ChatListTableViewCell.identifier
    
    private lazy var chatListTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 80
        tableView.register(ChatListTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.separatorStyle = .none
        tableView.delegate = self
        
        return tableView
    }()
    
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

    override func viewDidLoad() {
        super.viewDidLoad()

        self.bindViewModel()
        self.setUI()
        
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { [weak self] _ in
            self?.bindViewModel()
            self?.setUI()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        
        bindViewModel()
    }
    
}

extension ChatListViewController {
    
    private func setUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(chatListTableView)
        setNavigationUI()
        configureConstraints()
    }
    
    private func bindViewModel() {
        let input = ViewModel.Input(getChatListSubject: getChatListSubject.eraseToAnyPublisher())
        let output = viewModel.transform(input: input)
        
        bindChatListOutput(output)
    }
    
    private func bindChatListOutput(_ output: ViewModel.Output) {
        output.chatList.receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    dump(error)
                }
            } receiveValue: { [weak self] value in
                self?.generateData(items: value.chatList)
            }
            .store(in: &cancellableBag)
    }

    private func setNavigationUI() {
        let titleLabel = UILabel()
        titleLabel.setTitle("채팅")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        self.navigationItem.backButtonDisplayMode = .minimal
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            chatListTableView.topAnchor.constraint(equalTo: view.topAnchor),
            chatListTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatListTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatListTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func generateData(items: [ChatListData]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ChatListData>()
        snapshot.appendSections([.chat])
        snapshot.appendItems(items)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
}

extension ChatListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let chat = dataSource.itemIdentifier(for: indexPath) else { return }
        
        let chatRoomVC = ChatRoomViewController(roomID: chat.roomID)
        chatRoomVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(chatRoomVC, animated: true)
    }
    // TODO: after 15
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
//    -> UISwipeActionsConfiguration? {
//        let delete = UIContextualAction(style: .destructive, title: "삭제") { _, _, completion in
//            self.handleDeleteAction(forRowAt: indexPath)
//            completion(true)
//        }
//        let configuration = UISwipeActionsConfiguration(actions: [delete])
//        
//        return configuration
//    }
    
    func handleDeleteAction(forRowAt indexPath: IndexPath) {
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alertController.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = .myChatMessage
        
        let attributedTitle = NSAttributedString(
            string: "",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        alertController.setValue(attributedTitle, forKey: "attributedTitle")
        
        let attributedMessage = NSAttributedString(
            string: "채팅방을 나가면 채팅 목록 및 대화 내용이 삭제되고 복구할 수 없어요. \n채팅방에서 나가시겠어요?",
            attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16.0)]
        )
        alertController.setValue(attributedMessage, forKey: "attributedMessage")
        
        let okAction = UIAlertAction(title: "삭제", style: .default) { (_) in
            self.handleAlertOKAction()
        }
        okAction.setValue(UIColor.white, forKey: "titleTextColor")
        alertController.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        cancelAction.setValue(UIColor.systemRed, forKey: "titleTextColor")
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: false, completion: nil)
    }
    
    func handleAlertOKAction() {
        print("ok.")
        viewModel.deleteChatRoom(roomID: 1)
    }
    
}
