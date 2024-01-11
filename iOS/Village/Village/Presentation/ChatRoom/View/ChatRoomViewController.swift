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
    
    private let viewModel: ViewModel
    private let roomIDPublisher = PassthroughSubject<Void, Never>()
    private let postPublisher = PassthroughSubject<Void, Never>()
    private let userPublisher = PassthroughSubject<Void, Never>()
    private let blockPublisher = PassthroughSubject<Void, Never>()
    private let reportPublisher = PassthroughSubject<Void, Never>()
    private let joinPublisher = PassthroughSubject<Void, Never>()
    private let sendPublisher = PassthroughSubject<Void, Never>()
    private let pushPublisher = PassthroughSubject<Void, Never>()
    private var cancellableBag = Set<AnyCancellable>()
    
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
                    DispatchQueue.main.async {
                        cell.configureImage(image: self.viewModel.getMyImageData())
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
                    DispatchQueue.main.async {
                        cell.configureImage(image: self.viewModel.getOpponentImageData())
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
    // TODO: 사진전송버튼 기능구현
//    private lazy var keyboardMoreButton: UIButton = {
//        let button = UIButton()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setImage(UIImage(systemName: ImageSystemName.plus.rawValue), for: .normal)
//        button.tintColor = .primary500
//        
//        return button
//    }()
    
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
    
    private lazy var rentPostView: RentPostSummaryView = {
        let postView = RentPostSummaryView()
        postView.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(postViewTapped))
        postView.addGestureRecognizer(tapGesture)
        
        return postView
    }()
    
    private lazy var requestPostView: RequestPostSummaryView = {
        let postView = RequestPostSummaryView()
        postView.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(postViewTapped))
        postView.addGestureRecognizer(tapGesture)
        
        return postView
    }()
    
    private var blockAction: UIAlertAction {
        lazy var action = UIAlertAction(title: "사용자 차단하기", style: .destructive) { [weak self] _ in
            self?.blockPublisher.send()
        }
        return action
    }
    
    private var reportAction: UIAlertAction {
        lazy var action = UIAlertAction(title: "상대방 신고하기", style: .destructive) { [weak self] _ in
            self?.reportPublisher.send()
        }
        return action
    }
    
    private func report(postID: Int, userID: String) {
        let nextVC = ReportViewController(viewModel: ReportViewModel(
            userID: userID, postID: postID
        ))
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    private let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Should not be called")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        setSocket()
        setNavigationUI()
        setUI()
        setUpNotification()
        roomIDPublisher.send()
        view.backgroundColor = .systemBackground
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        WebSocket.shared.closeWebSocket()
    }
    
    private func setSocket() {
        WebSocket.shared.url = URL(string: "ws://www.village-api.store/chats")
        try? WebSocket.shared.openWebSocket()
        joinPublisher.send()
        
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
        sendPublisher.send()
    }    
    
    func sendJoinRoom(roomID: Int) {
        WebSocket.shared.sendJoinRoom(roomID: roomID)
    }
    
    func sendMessage(roomID: Int) {
        guard let currentUserID = JWTManager.shared.currentUserID else { return }
        if let text = self.keyboardTextField.text,
           !text.isEmpty {
            WebSocket.shared.sendMessage(
                roomID: roomID,
                sender: currentUserID,
                message: text,
                count: self.viewModel.getLog().count - 1
            )
            self.viewModel.appendLog(sender: currentUserID, message: text)
            let count = self.viewModel.getLog().count
            self.addGenerateData(chat: Message(sender: currentUserID, message: text, count: count-1))
            self.keyboardTextField.text = nil
            
            DispatchQueue.main.async {
                let rowIndex = self.viewModel.getLog().count-1
                self.chatTableView.scrollToRow(at: IndexPath(row: rowIndex, section: 0), at: .bottom, animated: false)
            }
        }
    }
    
    @objc func postViewTapped() {
        let viewControllers = self.navigationController?.viewControllers ?? []
        if viewControllers.count > 1 {
            pushPublisher.send()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func pushPostDetailVC(postID: Int) {
        let nextVC = PostDetailViewController(viewModel: PostDetailViewModel(postID: postID))
        nextVC.hidesBottomBarWhenPushed = true
        
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @objc func ellipsisTapped() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        // 차단 로직 추가구현
//        alert.addAction(blockAction)
        alert.addAction(reportAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
}

private extension ChatRoomViewController {
    
    func setUI() {
        view.addSubview(chatTableView)
        self.chatTableView.isHidden = true
        
        keyboardTextField.delegate = self
        
//        keyboardStackView.addArrangedSubview(keyboardMoreButton)
        keyboardStackView.addArrangedSubview(keyboardTextField)
        keyboardStackView.addArrangedSubview(keyboardSendButton)
        view.addSubview(keyboardStackView)
        
        configureConstraints()
    }
    
    func configureConstraints() {
        
        NSLayoutConstraint.activate([
            keyboardStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            keyboardStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            keyBoardStackViewBottomConstraint
        ])
        
//        keyboardMoreButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        NSLayoutConstraint.activate([
            keyboardTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            keyboardSendButton.widthAnchor.constraint(equalToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            chatTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            chatTableView.bottomAnchor.constraint(equalTo: keyboardStackView.topAnchor),
            chatTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            chatTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    func setNavigationUI() {
        let ellipsis = self.navigationItem.makeSFSymbolButton(
            self, action: #selector(ellipsisTapped), symbolName: .ellipsis
        )
        navigationItem.rightBarButtonItem = ellipsis
        navigationItem.backButtonDisplayMode = .minimal
    }
    
    func setNavigationTitle(user: UserDetail) {
        self.navigationItem.title = user.nickname
    }
    
    func bindViewModel() {
        let input = ViewModel.Input(
            roomIDInput: roomIDPublisher.eraseToAnyPublisher(),
            postInput: postPublisher.eraseToAnyPublisher(),
            userInput: userPublisher.eraseToAnyPublisher(),
            joinInput: joinPublisher.eraseToAnyPublisher(),
            sendInput: sendPublisher.eraseToAnyPublisher(),
            pushInput: pushPublisher.eraseToAnyPublisher(),
            blockInput: blockPublisher.eraseToAnyPublisher(),
            reportInput: reportPublisher.eraseToAnyPublisher()
        )
        let output = viewModel.transform(input: input)
        
        handlePost(output: output)
        handleUser(output: output)
        handleJoin(output: output)
        handleSend(output: output)
        handlePush(output: output)
        handleBlock(output: output)
        handleReport(output: output)
        handleReload(output: output)
    }
    
    func handlePost(output: ViewModel.Output) {
        output.postOutput.receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    dump(error)
                }
            }, receiveValue: { [weak self] post in
                self?.setPostContent(post: post)
                self?.generateData()
            })
            .store(in: &cancellableBag)
    } 
    
    func handleUser(output: ViewModel.Output) {
        output.userOutput.receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    dump(error)
                }
            } receiveValue: { [weak self] user in
                self?.setNavigationTitle(user: user)
            }
            .store(in: &cancellableBag)
    }
    
    func handleJoin(output: ViewModel.Output) {
        output.joinOutput.receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] roomID in
                self?.sendJoinRoom(roomID: roomID)
            })
            .store(in: &cancellableBag)
    }    
    
    func handleSend(output: ViewModel.Output) {
        output.roomIDOutput.receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] roomID in
                self?.sendMessage(roomID: roomID)
            })
            .store(in: &cancellableBag)
    }
    
    func handlePush(output: ViewModel.Output) {
        output.postIDOutput.receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] postID in
                self?.pushPostDetailVC(postID: postID)
            })
            .store(in: &cancellableBag)
    }
    
    func handleBlock(output: ViewModel.Output) {
        output.popViewControllerOutput.receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    dump(error)
                }
            }, receiveValue: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .store(in: &cancellableBag)
    }
    
    func handleReport(output: ViewModel.Output) {
        output.reportOutput.receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    dump(error)
                }
            } receiveValue: { [weak self] value in
                self?.report(postID: value.postID, userID: value.userID)
            }
            .store(in: &cancellableBag)
    }
    
    func handleReload(output: ViewModel.Output) {
        output.tableViewReloadOutput
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                var snapshot = self.dataSource.snapshot()
                snapshot.reconfigureItems(snapshot.itemIdentifiers)
                self.dataSource.apply(snapshot)
            }
            .store(in: &cancellableBag)
    }
    
    func setPostContent(post: PostDetail) {
        if post.isRequest == true {
            view.addSubview(self.requestPostView)
            NSLayoutConstraint.activate([
                requestPostView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                requestPostView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                requestPostView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                requestPostView.heightAnchor.constraint(equalToConstant: 80),
                chatTableView.topAnchor.constraint(equalTo: requestPostView.bottomAnchor)
                
            ])
            self.requestPostView.configureData(post: post)
        } else {
            view.addSubview(self.rentPostView)
            NSLayoutConstraint.activate([
                rentPostView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                rentPostView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                rentPostView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                rentPostView.heightAnchor.constraint(equalToConstant: 80),
                chatTableView.topAnchor.constraint(equalTo: rentPostView.bottomAnchor)
            ])
            self.rentPostView.configureData(post: post)
        }
        
        DispatchQueue.main.async {
            if self.viewModel.getLog().count-1 > 0 {
                self.chatTableView.scrollToRow(
                    at: IndexPath(row: self.viewModel.getLog().count-1, section: 0), at: .bottom, animated: false
                )
                self.chatTableView.isHidden = false
            }
        }
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
        keyBoardStackViewBottomConstraint.constant = -keyboardFrame.height
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        keyBoardStackViewBottomConstraint.constant = -20
    }
    
}

extension ChatRoomViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
