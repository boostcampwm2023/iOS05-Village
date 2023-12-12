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

    private let makeRoomPublisher = PassthroughSubject<Void, Never>()
    private let modifyPublisher = PassthroughSubject<Void, Never>()
    private let reportPublisher = PassthroughSubject<Void, Never>()
    private let morePublisher = PassthroughSubject<Void, Never>()
    private var deletePostID = PassthroughSubject<Void, Never>()
    private let hidePost = PassthroughSubject<Void, Never>()
    private let blockUser = PassthroughSubject<Void, Never>()
    
    let refreshPreviousViewController = PassthroughSubject<Void, Never>()
    
    private let viewModel: ViewModel
    private var cancellableBag = Set<AnyCancellable>()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        return scrollView
    }()
    
    private lazy var scrollViewContainerView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 10
        stackView.axis = .vertical
        
        return stackView
    }()
    
    private lazy var imagePageView: ImagePageView = {
        let imagePageView = ImagePageView()
        imagePageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imagePageView
    }()
    
    private lazy var postContentView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 10
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.axis = .vertical
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
        
        return stackView
    }()
    
    private lazy var userInfoView: UserInfoView = {
        let view = UserInfoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var postInfoView: PostInfoView = {
        let view = PostInfoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var footerView: UIView = {
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
    
    private lazy var priceLabel: PriceLabel = {
        let priceLabel = PriceLabel()
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        return priceLabel
    }()
    
    private lazy var chatButton: UIButton = {
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
            self?.modifyPublisher.send()
        }
        return action
    }
    
    private func modify(post: PostResponseDTO) {
        let useCase = PostCreateUseCase(postCreateRepository: PostCreateRepository())
        let postCreateViewModel = PostCreateViewModel(
            useCase: useCase,
            isRequest: post.isRequest,
            isEdit: true,
            postID: post.postID
        )
        let editVC = PostCreateViewController(viewModel: postCreateViewModel)
        editVC.editButtonTappedSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                // TODO: getpost 인자 빼기
                self?.viewModel.getPost(id: post.postID)
                self?.refreshPreviousViewController.send()
            }
            .store(in: &editVC.cancellableBag)
        let editNC = UINavigationController(rootViewController: editVC)
        editNC.modalPresentationStyle = .fullScreen
        self.present(editNC, animated: true)
    }
    
    private var deleteAction: UIAlertAction {
        lazy var action = UIAlertAction(title: "삭제하기", style: .destructive) { [weak self] _ in
            self?.deletePostID.send()
        }
        return action
    }
    
    private var hideAction: UIAlertAction {
        lazy var action = UIAlertAction(title: "게시글 숨기기", style: .default) { [weak self] _ in
            self?.hidePost.send()
        }
        return action
    }
    
    private var banAction: UIAlertAction {
        lazy var action = UIAlertAction(title: "사용자 차단하기", style: .destructive) { [weak self] _ in
            self?.blockUser.send()
        }
        return action
    }
    
    private var reportAction: UIAlertAction {
        lazy var action = UIAlertAction(title: "신고하기", style: .destructive) { [weak self] _ in
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
        
        bindingViewModel()
        configureUI()
        configureNavigationItem()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Should not be called")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
    }
    
    @objc
    private func moreBarButtonTapped() {
        morePublisher.send()
    }
    
    private func moreBarButtonAction(userID: String) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if userID != JWTManager.shared.currentUserID {
            alert.addAction(hideAction)
            alert.addAction(banAction)
            alert.addAction(reportAction)
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
        let viewControllers = self.navigationController?.viewControllers ?? []
        if viewControllers.count > 2 {
            self.navigationController?.popViewController(animated: true)
        } else {
            makeRoomPublisher.send()
        }
    }
    
    private func pushChatRoomViewController(roomID: PostRoomResponseDTO) {
        let nextVC = ChatRoomViewController(roomID: roomID.roomID)
        nextVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    private func setPostContent(post: PostResponseDTO) {
        if post.images.isEmpty {
            imagePageView.isHidden = true
        }
        if post.price == nil {
            priceLabel.isHidden = true
        }
        postInfoView.setContent(title: post.title,
                                startDate: post.startDate, 
                                endDate: post.endDate,
                                description: post.description)
        imagePageView.setImageURL(post.images)
        priceLabel.setPrice(price: post.price)
    }
    
    private func setUserContent(user: UserResponseDTO?) {
        if let user = user {
            userInfoView.setContent(imageURL: user.profileImageURL, nickname: user.nickname)
        } else {
            userInfoView.setContent(imageURL: nil, nickname: "(탈퇴한 회원)")
        }
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
        
        setLayoutConstraints()
    }
    
    func configureNavigationItem() {
        let rightBarButton = self.navigationItem.makeSFSymbolButton(
            self, action: #selector(moreBarButtonTapped), symbolName: .ellipsis
        )
        self.navigationItem.rightBarButtonItem = rightBarButton
        self.navigationItem.backButtonDisplayMode = .minimal
    }
    
    private func bindingViewModel() {
        let input = PostDetailViewModel.Input(
            makeRoomID: makeRoomPublisher.eraseToAnyPublisher(),
            moreInput: morePublisher.eraseToAnyPublisher(),
            modifyInput: modifyPublisher.eraseToAnyPublisher(),
            reportInput: reportPublisher.eraseToAnyPublisher(),
            deleteInput: deletePostID.eraseToAnyPublisher(),
            hideInput: hidePost.eraseToAnyPublisher(),
            blockUserInput: blockUser.eraseToAnyPublisher()
        )
        let output = viewModel.transformPost(input: input)
        
        handlePost(output: output)
        handleUser(output: output)
        handleRoomID(output: output)
        handleMore(output: output)
        handleModify(output: output)
        handleReport(output: output)
        handleDelete(output: output)
        handlePopViewControllerOutput(output: output)
    }
    
    private func handlePost(output: ViewModel.Output) {
        output.post.receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    dump(error)
                }
            }, receiveValue: { [weak self] post in
                self?.setPostContent(post: post)
                self?.setIsRequestConstraints(isRequest: post.isRequest)
                
                if post.userID == JWTManager.shared.currentUserID {
                    self?.chatButton.isEnabled = false
                    self?.chatButton.backgroundColor = .gray
                    self?.chatButton.alpha = 0.4
                }
            })
            .store(in: &cancellableBag)
    }    
    
    private func handleUser(output: ViewModel.Output) {
        output.user.receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(_:):
                    self.setUserContent(user: nil)
                    self.chatButton.isEnabled = false
                    self.chatButton.backgroundColor = .userChatMessage
                }
            } receiveValue: { [weak self] user in
                self?.setUserContent(user: user)
                self?.chatButton.backgroundColor = .primary500
            }
            .store(in: &cancellableBag)
    }    
    
    private func handleRoomID(output: ViewModel.Output) {
        output.roomID.receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    dump(error)
                }
            } receiveValue: { [weak self] roomID in
                self?.pushChatRoomViewController(roomID: roomID)
            }
            .store(in: &cancellableBag)
    }    
    
    private func handleMore(output: ViewModel.Output) {
        output.moreOutput.receive(on: DispatchQueue.main)
            .sink { [weak self] userID in
                self?.moreBarButtonAction(userID: userID)
            }
            .store(in: &cancellableBag)
    }    
    
    private func handleModify(output: ViewModel.Output) {
        output.modifyOutput.receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    dump(error)
                }
            }, receiveValue: { [weak self] post in
                self?.modify(post: post)
            })
            .store(in: &cancellableBag)
    }    
    
    private func handleReport(output: ViewModel.Output) {
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
    
    private func handleDelete(output: ViewModel.Output) {
        output.deleteOutput.receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    dump(error)
                }
            }, receiveValue: { [weak self] in
                self?.refreshPreviousViewController.send()
                self?.navigationController?.popViewController(animated: true)
            })
            .store(in: &cancellableBag)
    }   
    
    private func handlePopViewControllerOutput(output: ViewModel.Output) {
        output.popViewControllerOutput.receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    dump(error)
                }
            }, receiveValue: { [weak self] in
                self?.refreshPreviousViewController.send()
                self?.navigationController?.popViewController(animated: true)
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
        
        chatButton.centerYAnchor.constraint(equalTo: footerView.centerYAnchor).isActive = true
    }
    
    func setIsRequestConstraints(isRequest: Bool) {
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
    }
    
}
