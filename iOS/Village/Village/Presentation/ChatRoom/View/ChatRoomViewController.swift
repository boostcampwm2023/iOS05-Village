//
//  ChatRoomViewController.swift
//  Village
//
//  Created by 박동재 on 2023/11/20.
//

import UIKit
import Combine

final class ChatRoomViewController: UIViewController {
    
    typealias ChatRoomDataSource = UITableViewDiffableDataSource<Section, Message>
    typealias ViewModel = ChatRoomViewModel
    
    enum Section {
        case room
    }
    
    private var viewModel = ViewModel()
    private var cancellableBag = Set<AnyCancellable>()
    
    private let roomID: Just<Int>
    private var writer: String?
    private var user: String?
    
//    private var imageURL: String?
    private var postID: AnyPublisher<Int, Never>?
    
    private let reuseIdentifier = ChatRoomTableViewCell.identifier
    private lazy var chatTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(ChatRoomTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.register(OpponentChatTableViewCell.self, forCellReuseIdentifier: OpponentChatTableViewCell.identifier)
        tableView.separatorStyle = .none
        
        return tableView
    }()
    
    private lazy var dataSource: ChatRoomDataSource = ChatRoomDataSource(
        tableView: chatTableView,
        cellProvider: { [weak self] (tableView, indexPath, message) in
            guard let self = self else { return ChatRoomTableViewCell() }
            if message.sender == JWTManager.shared.currentUserID {
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: ChatRoomTableViewCell.identifier,
                    for: indexPath) as? ChatRoomTableViewCell else {
                    return ChatRoomTableViewCell()
                }
                cell.configureData(message: message.message)
                if viewModel.checkSender(message: message) {
                    if message.sender == self.user {
                        cell.configureImage(image: viewModel.getUserData())
                    } else {
                        cell.configureImage(image: viewModel.getWriterData())
                    }
                }
                cell.selectionStyle = .none
                
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: OpponentChatTableViewCell.identifier,
                    for: indexPath) as? OpponentChatTableViewCell else {
                    return OpponentChatTableViewCell()
                }
                cell.configureData(message: message.message)
                if viewModel.checkSender(message: message) {
                    if message.sender == self.user {
                        cell.configureImage(image: viewModel.getUserData())
                    } else {
                        cell.configureImage(image: viewModel.getWriterData())
                    }
                }
                cell.selectionStyle = .none
                
                return cell
            }
        }
    )
    
    private lazy var keyboardStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        
        return stackView
    }()
    
    private lazy var keyBoardStackViewBottomConstraint = keyboardStackView.bottomAnchor.constraint(
        equalTo: view.safeAreaLayoutGuide.bottomAnchor, 
        constant: -20
    )
    
    private lazy var keyboardMoreButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: ImageSystemName.plus.rawValue), for: .normal)
        button.tintColor = .primary500
        
        return button
    }()
    
    private lazy var keyboardTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "메시지를 입력해주세요."
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .keyboardTextField
        
        return textField
    }()
    
    private lazy var keyboardSendButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: ImageSystemName.paperplane.rawValue), for: .normal)
        button.addTarget(target, action: #selector(sendbuttonTapped), for: .touchUpInside)
        button.tintColor = .primary500
        
        return button
    }()
    
    private lazy var postView: PostView = {
        let postView = PostView()
        postView.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(postViewTapped))
        postView.addGestureRecognizer(tapGesture)
        
        return postView
    }()
    
    init(roomID: Int) {
        self.roomID = Just(roomID)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Should not be called")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSocket()
        bindViewModel()
        DispatchQueue.main.async {
            if !self.viewModel.getLog().isEmpty {
                self.chatTableView.scrollToRow(
                    at: IndexPath(row: self.viewModel.getLog().count-1, section: 0), at: .bottom, animated: false
                )
            }
        }
        setNavigationUI()
        setUI()
        setUpNotification()
        view.backgroundColor = .systemBackground
    }
    
    func setSocket() {
        WebSocket.shared.url = URL(string: "ws://www.village-api.shop/chats")
        try? WebSocket.shared.openWebSocket()
        self.roomID.receive(on: DispatchQueue.main)
            .sink { roomID in
                WebSocket.shared.sendJoinRoom(roomID: roomID)
            }
            .store(in: &cancellableBag)
        
        MessageManager.shared.messageSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                let data = data.data
                self?.viewModel.appendLog(sender: data.sender, message: data.message)
                guard let count = self?.viewModel.getLog().count else { return }
                self?.addGenerateData(chat: Message(sender: data.sender, message: data.message, count: count))
                self?.chatTableView.scrollToRow(at: IndexPath(row: count-1, section: 0), at: .bottom, animated: false)
            }
            .store(in: &cancellableBag)
    }
    
}

private extension ChatRoomViewController {
    
    @objc func sendbuttonTapped() {
        guard let currentUserID = JWTManager.shared.currentUserID else { return }
        if let text = self.keyboardTextField.text,
           !text.isEmpty {
            self.roomID.receive(on: DispatchQueue.main)
                .sink { [weak self] roomID in
                    WebSocket.shared.sendMessage(
                        roomID: roomID,
                        sender: currentUserID,
                        message: text,
                        count: (self?.viewModel.getLog().count ?? 1) - 1
                    )
                    self?.viewModel.appendLog(sender: currentUserID, message: text)
                    guard let count = self?.viewModel.getLog().count else { return }
                    self?.addGenerateData(chat: Message(sender: currentUserID, message: text, count: count-1))
                }
                .store(in: &cancellableBag)
            self.keyboardTextField.text = nil
            DispatchQueue.main.async {
                let rowIndex = self.viewModel.getLog().count-1
                self.chatTableView.scrollToRow(at: IndexPath(row: rowIndex, section: 0), at: .bottom, animated: false)
            }
        }
    }
    
    @objc private func postViewTapped() {
        let viewControllers = self.navigationController?.viewControllers ?? []
        if viewControllers.count > 1 {
            guard let postID = self.postID else { return }
            postID.sink(receiveValue: { value in
                let nextVC = PostDetailViewController(postID: value)
                nextVC.hidesBottomBarWhenPushed = true
                
                self.navigationController?.pushViewController(nextVC, animated: true)
            })
            .store(in: &cancellableBag)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func ellipsisTapped() {
        // TODO: 더보기 버튼 클릭 액션
    }
    
}

private extension ChatRoomViewController {
    
    func setUI() {
        setNavigationTitle(title: self.opponentNickname)
        view.addSubview(postView)
        view.addSubview(chatTableView)
        
        keyboardTextField.delegate = self
        
        keyboardStackView.addArrangedSubview(keyboardMoreButton)
        keyboardStackView.addArrangedSubview(keyboardTextField)
        keyboardStackView.addArrangedSubview(keyboardSendButton)
        view.addSubview(keyboardStackView)
        
        configureConstraints()
    }
    
    func configureConstraints() {
        
        NSLayoutConstraint.activate([
            keyboardStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyboardStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keyBoardStackViewBottomConstraint
        ])
        
        keyboardMoreButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        keyboardTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        keyboardSendButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        NSLayoutConstraint.activate([
            postView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            postView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            postView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            postView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        NSLayoutConstraint.activate([
            chatTableView.topAnchor.constraint(equalTo: postView.bottomAnchor),
            chatTableView.bottomAnchor.constraint(equalTo: keyboardStackView.topAnchor),
            chatTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func setNavigationUI() {
        let ellipsis = self.navigationItem.makeSFSymbolButton(
            self, action: #selector(ellipsisTapped), symbolName: .ellipsis
        )
        navigationItem.rightBarButtonItem = ellipsis
        navigationItem.backButtonDisplayMode = .minimal
    }
    
    func setNavigationTitle(title: String) {
        navigationItem.title = title
    }
    
    func bindViewModel() {
        let output = viewModel.transformRoom(input: ViewModel.RoomInput(roomID: roomID.eraseToAnyPublisher()))
        
        bindRoomOutput(output)
    }
    
    func bindRoomOutput(_ output: ViewModel.RoomOutput) {
        output.chatRoom
                    .receive(on: DispatchQueue.main)
                    .sink { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            dump(error)
                        }
                    } receiveValue: { [weak self] room in
                        self?.setRoomContent(room: room)
                        guard let isEmpty = self?.viewModel.getLog().isEmpty else { return }
                        if !isEmpty {
                            guard let count = self?.viewModel.getLog().count else { return }
                            self?.chatTableView.scrollToRow(
                                at: IndexPath(row: count-1, section: 0), at: .bottom, animated: false
                            )
                        }
                    }
                    .store(in: &cancellableBag)
    }
    
    func setRoomContent(room: GetRoomResponseDTO) {
        room.chatLog.forEach { [weak self] chat in
            self?.viewModel.appendLog(sender: chat.sender, message: chat.message)
        }
        self.writer = room.writer
        self.user = room.user
        self.viewModel.getData(writerURL: room.writerProfileIMG, userURL: room.userProfileIMG)
        self.generateData()
        
        self.postID = Just(room.postID).eraseToAnyPublisher()
        guard let postID = self.postID else { return }
        let output = viewModel.transformPost(input: ViewModel.PostInput(postID: postID))
        bindPostOutput(output)
    }
    
    private func bindPostOutput(_ output: ViewModel.PostOutput) {
        output.post.receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    dump(error)
                }
            } receiveValue: { [weak self] post in
                self?.setPostContent(post: post)
            }
            .store(in: &cancellableBag)
    }
    
    private func setPostContent(post: PostResponseDTO) {
        postView.setContent(url: post.imageURL.first ?? "", title: post.title, price: String(post.price ?? 0))
    }
    
    func generateData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Message>()
        snapshot.appendSections([.room])
        snapshot.appendItems(viewModel.getLog())

        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func addGenerateData(chat: Message) {
        var snapshot = dataSource.snapshot()
        snapshot.appendItems([chat], toSection: .room)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func setUpNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo as NSDictionary?,
              var keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        keyboardFrame = view.convert(keyboardFrame, from: nil)
        keyBoardStackViewBottomConstraint.isActive = false
        keyBoardStackViewBottomConstraint = keyboardStackView
            .bottomAnchor
            .constraint(
                equalTo: view.bottomAnchor,
                constant: -keyboardFrame.height
            )
        keyBoardStackViewBottomConstraint.isActive = true
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo as NSDictionary?,
              var keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        keyboardFrame = view.convert(keyboardFrame, from: nil)
        keyBoardStackViewBottomConstraint.isActive = false
        keyBoardStackViewBottomConstraint = keyboardStackView
            .bottomAnchor
            .constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -20
            )
        keyBoardStackViewBottomConstraint.isActive = true
    }
    
}

extension ChatRoomViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
