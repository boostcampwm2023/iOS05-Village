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
    
    private lazy var dataSource: ChatRoomDataSource = ChatRoomDataSource(
        tableView: chatTableView,
        cellProvider: { [weak self] (tableView, indexPath, message) in
            guard let self = self else { return ChatRoomTableViewCell() }
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: self.reuseIdentifier,
                for: indexPath) as? ChatRoomTableViewCell else {
                return ChatRoomTableViewCell()
            }
            cell.configureData(
                message: message.message,
                profileImageURL: "",
                // TODO: 나중에 해시값으로 바꾸기
                isMine: message.sender == "me"
            )
            cell.selectionStyle = .none
            return cell
        }
    )
    private let reuseIdentifier = ChatRoomTableViewCell.identifier
    private lazy var chatTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.register(ChatRoomTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.separatorStyle = .none
        
        return tableView
    }()
    
    private var viewModel = ViewModel()
    private var cancellableBag = Set<AnyCancellable>()
    
    enum Section {
        case room
    }
    
    private let roomID: Just<Int>
    private let opponentNickname: Just<String>
    
    private var imageURL: String?
    private var postID: AnyPublisher<Int, Never>?
    
    private let keyboardStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        
        return stackView
    }()
    private lazy var keyBoardStackViewBottomConstraint = keyboardStackView.bottomAnchor.constraint(
        equalTo: view.safeAreaLayoutGuide.bottomAnchor, 
        constant: -20
    )
    
    private let keyboardMoreButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: ImageSystemName.plus.rawValue), for: .normal)
        button.tintColor = .primary500
        
        return button
    }()
    
    private let keyboardTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "메시지를 입력해주세요."
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .grey100
        
        return textField
    }()
    
    @objc func sendbuttonTapped() {
        if let text = self.keyboardTextField.text,
           !text.isEmpty {
            WebSocket.shared.sendMessage(roomID: "164", sender: "me", message: text)
            viewModel.appendLog(sender: "me", message: text)
            generateData()
            self.keyboardTextField.text = nil
        }
    }
    
    private let keyboardSendButton: UIButton = {
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
    
    @objc private func postViewTapped() {
        var viewControllers = self.navigationController?.viewControllers ?? []
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
    
    init(roomID: Int, opponentNickname: String) {
        self.roomID = Just(roomID)
        self.opponentNickname = Just(opponentNickname)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Should not be called")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSocket()
        bindViewModel()
        setNavigationUI()
        setUI()
        generateData()
        setUpNotification()
        view.backgroundColor = .systemBackground
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        WebSocket.shared.sendDisconnectRoom(roomID: "164")
    }
    
    @objc private func ellipsisTapped() {
        // TODO: 더보기 버튼 클릭 액션
    }
    
    func setSocket() {
        WebSocket.shared.url = URL(string: "ws://www.village-api.shop/chats")
        try? WebSocket.shared.openWebSocket()
        WebSocket.shared.sendJoinRoom(roomID: "164")
        
        MessageManager.shared.messageSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                let sender = message.sender
                let message = message.message
                self?.viewModel.appendLog(sender: sender, message: message)
                self?.generateData()
//                self?.viewModel.appendLog(newLog: message)
            }
            .store(in: &cancellableBag)
    }
    
}

private extension ChatRoomViewController {
    
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
                        self?.generateData()
                    }
                    .store(in: &cancellableBag)
    }
    
    func setUI() {
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
    
    func setRoomContent(room: GetRoomResponseDTO) {
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
        if let log = viewModel.getLog() {
            snapshot.appendItems(log)
        }
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
