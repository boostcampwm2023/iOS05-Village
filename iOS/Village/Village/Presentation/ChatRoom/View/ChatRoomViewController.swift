//
//  ChatRoomViewController.swift
//  Village
//
//  Created by 박동재 on 2023/11/20.
//

import UIKit
import Combine

final class ChatRoomViewController: UIViewController {
    
    typealias ChatRoomDataSource = UICollectionViewDiffableDataSource<Section, Message>
    typealias ViewModel = ChatRoomViewModel
    typealias Input = ViewModel.Input
    
    private var dataSource: ChatRoomDataSource!
    private let reuseIdentifier = ChatRoomCollectionViewCell.identifier
    private var collectionView: UICollectionView!
    
    private var viewModel = ViewModel()
    private var cancellableBag = Set<AnyCancellable>()
    
    enum Section {
        case room
    }
    
    private let roomID: Just<Int>
    
    private var imageURL: String?
    
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
    
    private let postView: PostView = {
        let postView = PostView()
        postView.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        bindViewModel()
        setNavigationUI()
        comfigureCollectionView()
        setUI()
        configureDataSource()
        generateData()
        view.backgroundColor = .systemBackground
    }
    
    @objc private func ellipsisTapped() {
        // TODO: 더보기 버튼 클릭 액션
    }
    
}

private extension ChatRoomViewController {
    
    func comfigureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
    }
    
    func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(60)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 10.0, leading: 0.0, bottom: 4.0, trailing: 0.0)
        section.interGroupSpacing = 8.0
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func bindViewModel() {
        let output = viewModel.transform(input: ViewModel.Input(roomID: roomID.eraseToAnyPublisher()))
        
        bindRoomOutput(output)
    }
    
    func bindRoomOutput(_ output: ViewModel.Output) {
        if let room = viewModel.getTest() {
            self.setRoomContent(room: room)
        }
//        output.chatRoom
//            .receive(on: DispatchQueue.main)
//            .sink(receiveValue: { room in
//                self.setRoomContent(room: room)
//            })
//            .store(in: &cancellableBag)
    }
    
    func setUI() {
        view.addSubview(postView)
        
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
        
        NSLayoutConstraint.activate([
            postView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            postView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            postView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            postView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: postView.bottomAnchor, constant: 0),
            collectionView.bottomAnchor.constraint(equalTo: keyboardStackView.topAnchor, constant: 0),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
        ])
    }
    
    func setNavigationUI() {
        let ellipsis = self.navigationItem.makeSFSymbolButton(
            self, action: #selector(ellipsisTapped), symbolName: .ellipsis
        )
        navigationItem.rightBarButtonItem = ellipsis
    }
    
    func setNavigationTitle(title: String) {
        navigationItem.title = title
    }
    
    func setRoomContent(room: ChatRoomResponseDTO) {
        imageURL = room.postImage
        setNavigationTitle(title: room.user)
        postView.setContent(url: room.postImage, title: room.postName, price: room.postPrice)
    }
    
    func configureDataSource() {
        collectionView.register(ChatRoomCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        dataSource = ChatRoomDataSource(collectionView: collectionView) { (collectionView, indexPath, message) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: self.reuseIdentifier,
                for: indexPath
            ) as? ChatRoomCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.configureData(message: message.body, profileImageURL: self.imageURL!)
            print(message)
            return cell
        }
    }
    
    func generateData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Message>()
        snapshot.appendSections([.room])
        snapshot.appendItems(viewModel.getTest()!.chatLog)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
}

extension ChatRoomViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
