//
//  ChatRoomViewController.swift
//  Village
//
//  Created by 박동재 on 2023/11/20.
//

import UIKit
import Combine

final class ChatRoomViewController: UIViewController {
    
    typealias ChatRoomDataSource = UICollectionViewDiffableDataSource<Section, ChatRoomResponseDTO>
    typealias ViewModel = ChatRoomViewModel
    typealias Input = ViewModel.Input
    
    private var dataSource: ChatRoomDataSource!
    private let reuseIdentifier = ChatListCollectionViewCell.identifier
    private var collectionView: UICollectionView!
    
    private var viewModel = ViewModel()
    private var cancellableBag = Set<AnyCancellable>()
    
    enum Section {
        case room
    }
    
    private let roomID: Just<Int>
    
    init(roomID: Int) {
        self.roomID = Just(roomID)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Should not be called")
    }
    
    private let keyboardStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        
        return stackView
    }()
    
    private let keyboardMoreButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: ImageSystemName.plus.rawValue), for: .normal)
        
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
    
    private let keyboardSendButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: ImageSystemName.paperplane.rawValue), for: .normal)
        
        return button
    }()
    
    private let postSummaryView = PostSummaryView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationUI()
        setUI()
        bindViewModel()
        
        view.backgroundColor = .systemBackground
    }
    
    private func bindViewModel() {
        let output = viewModel.transform(input: ViewModel.Input(roomID: roomID.eraseToAnyPublisher()))
        
        bindRoomOutput(output)
    }
    
    private func bindRoomOutput(_ output: ViewModel.Output) {
        output.chatRoom
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    dump(error)
                }
            }, receiveValue: { [weak self] room in
                self?.setPostContent(room: room)
            })
            .store(in: &cancellableBag)
    }
    
    private func setUI() {
        view.addSubview(postSummaryView)
        
        keyboardTextField.delegate = self
        
        keyboardStackView.addArrangedSubview(keyboardMoreButton)
        keyboardStackView.addArrangedSubview(keyboardTextField)
        keyboardStackView.addArrangedSubview(keyboardSendButton)
        view.addSubview(keyboardStackView)
        
        configureConstraints()
    }
    
    private func configureConstraints() {
        
        NSLayoutConstraint.activate([
            keyboardStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyboardStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keyboardStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            keyboardMoreButton.widthAnchor.constraint(equalToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            keyboardTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            keyboardSendButton.widthAnchor.constraint(equalToConstant: 40)
        ])
        
    }
    
    private func setNavigationUI() {
        let ellipsis = self.navigationItem.makeSFSymbolButton(
            self, action: #selector(ellipsisTapped), symbolName: .ellipsis
        )
        
        navigationItem.title = "다른 사용자"
        navigationItem.rightBarButtonItem = ellipsis
    }
    
    @objc private func ellipsisTapped() {
        // TODO: 더보기 버튼 클릭 액션
    }
    
    private func setPostContent(room: ChatRoomResponseDTO) {
        print(room)
    }
}

extension ChatRoomViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
