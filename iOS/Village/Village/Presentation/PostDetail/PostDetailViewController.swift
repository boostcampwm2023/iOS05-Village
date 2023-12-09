//
//  PostDetailViewController.swift
//  Village
//
//  Created by 박동재 on 2023/11/17.
//

import UIKit
import Combine

final class PostDetailViewController: UIViewController {
    
    typealias ViewModel = PostDetailViewModel
    typealias Input = ViewModel.Input
    
    private let postID: Just<Int>
    private var userID: Just<String>?
    private var isRequest: Bool?
    private var deletePostID = PassthroughSubject<Int, Never>()
    private let hidePost = PassthroughSubject<Int, Never>()
    
    private let viewModel = ViewModel()
    private var cancellableBag = Set<AnyCancellable>()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        return scrollView
    }()
    
    private var scrollViewContainerView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 10
        stackView.axis = .vertical
        
        return stackView
    }()
    
    private var imagePageView: ImagePageView = {
        let imagePageView = ImagePageView()
        imagePageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imagePageView
    }()
    
    private var postContentView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 10
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.axis = .vertical
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
        
        return stackView
    }()
    
    private var userInfoView: UserInfoView = {
        let view = UserInfoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private var postInfoView: PostInfoView = {
        let view = PostInfoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private var footerView: UIView = {
        let view = UIView()
        let divider = UIView.divider(.horizontal)
        view.addSubview(divider)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 70).isActive = true
        divider.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        divider.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        divider.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
        return view
    }()
    
    private var priceLabel: PriceLabel = {
        let priceLabel = PriceLabel()
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        return priceLabel
    }()
    
    private var chatButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .primary500
        let title = NSAttributedString(string: "채팅하기",
                                       attributes: [.font: UIFont.boldSystemFont(ofSize: 16),
                                                    .foregroundColor: UIColor.white])
        button.setAttributedTitle(title, for: .normal)
        button.layer.cornerRadius = 6
        button.addTarget(target, action: #selector(chatButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private var modifyAction: UIAlertAction {
        lazy var action = UIAlertAction(title: "편집하기", style: .default) { [weak self] _ in
            guard let isRequest = self?.isRequest  else {
                return
            }
            let useCase = PostCreateUseCase(postCreateRepository: PostCreateRepository())
            let postCreateViewModel = PostCreateViewModel(
                useCase: useCase,
                isRequest: isRequest,
                isEdit: true,
                postID: self?.postID.output
            )
            let editVC = PostCreateViewController(viewModel: postCreateViewModel)
            editVC.editButtonTappedSubject
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let id = self?.postID.output else { return }
                    self?.viewModel.getPost(id: id)
                }
                .store(in: &editVC.cancellableBag)
            let editNC = UINavigationController(rootViewController: editVC)
            editNC.modalPresentationStyle = .fullScreen
            self?.present(editNC, animated: true)
        }
        return action
    }
    
    private var deleteAction: UIAlertAction {
        lazy var action = UIAlertAction(title: "삭제하기", style: .destructive) { [weak self] _ in
            guard let id = self?.postID.output else { return }
            self?.deletePostID.send(id)
        }
        return action
    }
    
    private var hideAction: UIAlertAction {
        lazy var action = UIAlertAction(title: "게시글 숨기기", style: .default) { [weak self] _ in
            guard let id = self?.postID.output else { return }
            self?.hidePost.send(id)
        }
        return action
    }
    
    private var banAction: UIAlertAction {
        lazy var action = UIAlertAction(title: "사용자 차단하기", style: .default) { _ in
            // TODO: ban user
        }
        return action
    }
    
    private let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
    
    init(postID: Int) {
        self.postID = Just(postID)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Should not be called")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        configureUI()
        configureNavigationItem()
        bindPostViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let postDTO = viewModel.postDTO else { return }
        setPostContent(post: postDTO)
        viewModel.postDTO = postDTO

    }
    
    @objc
    private func moreBarButtonTapped() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        guard let postUserID = userID?.output else { return }
        if postUserID != JWTManager.shared.currentUserID {
            alert.addAction(hideAction)
            alert.addAction(banAction)
            alert.addAction(cancelAction)
        } else {
            alert.addAction(modifyAction)
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc
    private func chatButtonTapped() {
        guard let userID = self.userID?.output else { return }
        let roomID = viewModel.createChatRoom(writer: userID, postID: self.postID.output)
        let viewControllers = self.navigationController?.viewControllers ?? []
        if viewControllers.count > 2 {
            self.navigationController?.popViewController(animated: true)
        } else {
            pushChatRoomViewController(output: roomID)
        }
    }
            
    private func pushChatRoomViewController(output: PostDetailViewModel.RoomIDOutput) {
        guard let userID = self.userID?.output else { return }
        output.roomID.receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    dump(error)
                }
            } receiveValue: { [weak self] roomID in
                let nextVC = ChatRoomViewController(roomID: roomID.roomID, opponentNickname: userID)
                nextVC.hidesBottomBarWhenPushed = true
                self?.navigationController?.pushViewController(nextVC, animated: true)
            }
            .store(in: &cancellableBag)
    }
    
    private func setPostContent(post: PostResponseDTO) {
        if post.imageURL.isEmpty {
            imagePageView.isHidden = true
        }
        if post.price == nil {
            priceLabel.isHidden = true
        }
        postInfoView.setContent(title: post.title,
                                startDate: post.startDate, endDate: post.endDate,
                                description: post.description)
        imagePageView.setImageURL(post.imageURL)
        priceLabel.setPrice(price: post.price)
    }
    
    private func setUserContent(user: UserResponseDTO) {
        userInfoView.setContent(imageURL: user.profileImageURL, nickname: user.nickname)
    }

}

private extension PostDetailViewController {
    
    func configureUI() {
        view.addSubview(scrollView)
        view.addSubview(footerView)
        scrollView.addSubview(scrollViewContainerView)
        scrollViewContainerView.addArrangedSubview(imagePageView)
        scrollViewContainerView.addArrangedSubview(postContentView)
        postContentView.addArrangedSubview(userInfoView)
        postContentView.addArrangedSubview(UIView.divider(.horizontal))
        postContentView.addArrangedSubview(postInfoView)
        footerView.addSubview(priceLabel)
        footerView.addSubview(chatButton)
    }
    
    func configureNavigationItem() {
        let rightBarButton = self.navigationItem.makeSFSymbolButton(
            self, action: #selector(moreBarButtonTapped), symbolName: .ellipsis
        )
        self.navigationItem.rightBarButtonItem = rightBarButton
        self.navigationItem.backButtonDisplayMode = .minimal
    }
    
    private func bindPostViewModel() {
        let output = viewModel.transformPost(input: Input(
            postID: postID.eraseToAnyPublisher(),
            deleteInput: deletePostID.eraseToAnyPublisher(),
            hideInput: hidePost.eraseToAnyPublisher()
        ))
        
        bindPostOutput(output)
    }
    
    private func bindUserViewModel() {
        guard let userID = self.userID?.eraseToAnyPublisher() else { return }
        let output = viewModel.transformUser(input: ViewModel.UserInput(userID: userID))
        
        bindUserOutput(output)
    }
    
    private func bindPostOutput(_ output: ViewModel.Output) {
        output.post
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    dump(error)
                }
            }, receiveValue: { [weak self] post in
                self?.setPostContent(post: post)
                self?.isRequest = post.isRequest
                self?.userID = Just(post.userID)
                self?.setLayoutConstraints()
                
                self?.bindUserViewModel()
                
                if post.userID == JWTManager.shared.currentUserID {
                    self?.chatButton.isEnabled = false
                    self?.chatButton.backgroundColor = .gray
                    self?.chatButton.alpha = 0.4
                }
            })
            .store(in: &cancellableBag)
        
        output.deleteOutput
            .receive(on: DispatchQueue.main)
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
        
        output.hideOutput
            .receive(on: DispatchQueue.main)
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
    
    private func bindUserOutput(_ output: ViewModel.UserOutput) {
        output.user
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    dump(error)
                }
            }, receiveValue: { [weak self] user in
                self?.setUserContent(user: user)
            })
            .store(in: &cancellableBag)
    }
    
    func setLayoutConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: footerView.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            scrollViewContainerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollViewContainerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollViewContainerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollViewContainerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            imagePageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            imagePageView.heightAnchor.constraint(equalTo: imagePageView.widthAnchor, multiplier: 0.85)
        ])
        
        NSLayoutConstraint.activate([
            footerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        guard let isRequest = self.isRequest else { return }
        if isRequest {
            NSLayoutConstraint.activate([
                chatButton.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
                chatButton.widthAnchor.constraint(equalTo: footerView.widthAnchor, multiplier: 0.8),
                chatButton.heightAnchor.constraint(equalTo: footerView.heightAnchor, multiplier: 0.7)
            ])
        } else {
            NSLayoutConstraint.activate([
                chatButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -25),
                chatButton.widthAnchor.constraint(equalToConstant: 110),
                chatButton.heightAnchor.constraint(equalToConstant: 40),
                priceLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 25),
                priceLabel.trailingAnchor.constraint(lessThanOrEqualTo: chatButton.leadingAnchor, constant: -10),
                priceLabel.centerYAnchor.constraint(equalTo: chatButton.centerYAnchor)
            ])
        }
        
        chatButton.centerYAnchor.constraint(equalTo: footerView.centerYAnchor).isActive = true
    }
    
}
