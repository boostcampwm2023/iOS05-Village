//
//  MyPageViewController.swift
//  Village
//
//  Created by 박동재 on 2023/11/18.
//

import UIKit
import Combine

final class MyPageViewController: UIViewController {
    
    typealias ViewModel = MyPageViewModel
    typealias Input = ViewModel.Input
    
    private let viewModel: ViewModel
    private var cancellableBag: Set<AnyCancellable> = []
    
    private var logoutSubject = PassthroughSubject<Void, Never>()
    private var deleteAccountSubject = PassthroughSubject<Void, Never>()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .primary500
        imageView.setLayer(borderWidth: 0, cornerRadius: 16)
        imageView.backgroundColor = .primary100
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        
        return label
    }()
    
    private let hashIDLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        
        return label
    }()
    
    private lazy var profileEditButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.title = "프로필 수정"
        configuration.titleAlignment = .center
        configuration.baseForegroundColor = .label
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(profileEditButtonTapped), for: .touchUpInside)
        button.configuration = configuration
        button.contentHorizontalAlignment = .leading
        button.setLayer(borderWidth: 0)
        button.backgroundColor = .systemGray5
        
        return button
    }()
    
    private let activityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "내 활동"
        label.textColor = .secondaryLabel
        label.font = .boldSystemFont(ofSize: 14)
        
        return label
    }()
    
    private let activityStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        
        return stackView
    }()
    
    private let profileStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        
        return stackView
    }()
    
    private lazy var myPostButton: UIButton = {
        var titleAttr = AttributedString.init("내 게시글")
        titleAttr.font = .systemFont(ofSize: 16, weight: .bold)
        
        var configuration = UIButton.Configuration.plain()
        configuration.baseForegroundColor = .label
        configuration.attributedTitle = titleAttr
        configuration.buttonSize = .medium
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(myPostsButtonTapped), for: .touchUpInside)
        button.configuration = configuration
        button.contentHorizontalAlignment = .leading

        return button
    }()
    
    private lazy var hiddenPostButton: UIButton = {
        var titleAttr = AttributedString.init("숨긴 게시글")
        titleAttr.font = .systemFont(ofSize: 16, weight: .bold)
        
        var configuration = UIButton.Configuration.plain()
        configuration.baseForegroundColor = .label
        configuration.attributedTitle = titleAttr
        configuration.buttonSize = .medium
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(hiddenPostButtonTapped), for: .touchUpInside)
        button.configuration = configuration
        button.contentHorizontalAlignment = .leading
        
        return button
    }()
    
    private lazy var blockedUsersButton: UIButton = {
        var titleAttr = AttributedString.init("차단 관리")
        titleAttr.font = .systemFont(ofSize: 16, weight: .bold)
        
        var configuration = UIButton.Configuration.plain()
        configuration.baseForegroundColor = .label
        configuration.attributedTitle = titleAttr
        configuration.buttonSize = .medium
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(blockedUsersButtonTapped), for: .touchUpInside)
        button.configuration = configuration
        button.contentHorizontalAlignment = .leading
        
        return button
    }()
    
    private let accountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "계정"
        label.textColor = .secondaryLabel
        label.font = .boldSystemFont(ofSize: 14)
        
        return label
    }()
    
    private lazy var logoutButton: UIButton = {
        var titleAttr = AttributedString.init("로그아웃")
        titleAttr.font = .systemFont(ofSize: 16, weight: .bold)
        
        var configuration = UIButton.Configuration.plain()
        configuration.baseForegroundColor = .label
        configuration.attributedTitle = titleAttr
        configuration.buttonSize = .medium
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        button.configuration = configuration
        button.contentHorizontalAlignment = .leading
        
        return button
    }()
    
    private lazy var deleteAccountButton: UIButton = {
        var titleAttr = AttributedString.init("회원탈퇴")
        titleAttr.font = .systemFont(ofSize: 16, weight: .bold)
        
        var configuration = UIButton.Configuration.plain()
        configuration.baseForegroundColor = .label
        configuration.attributedTitle = titleAttr
        configuration.buttonSize = .medium
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(deleteAccountButtonTapped), for: .touchUpInside)
        button.configuration = configuration
        button.contentHorizontalAlignment = .leading
        
        return button
    }()
    
    private let accountStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        
        return stackView
    }()
    
    init(viewModel: MyPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationUI()
        setUI()
        setConstraints()
        bindViewModel()
        view.backgroundColor = .systemBackground
    }
    
}

private extension MyPageViewController {
    
    func setNavigationUI() {
        let titleLabel = UILabel()
        titleLabel.setTitle("마이페이지")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        self.navigationItem.backButtonDisplayMode = .minimal
    }
    
    func setUI() {
        view.addSubview(profileImageView)
        
        view.addSubview(profileStackView)
        profileStackView.addArrangedSubview(nicknameLabel)
        profileStackView.setCustomSpacing(2, after: nicknameLabel)
        profileStackView.addArrangedSubview(hashIDLabel)
        profileStackView.setCustomSpacing(6, after: hashIDLabel)
        profileStackView.addArrangedSubview(profileEditButton)
        
        view.addSubview(activityStackView)
        activityStackView.addArrangedSubview(activityLabel)
        activityStackView.addArrangedSubview(myPostButton)
        activityStackView.addArrangedSubview(hiddenPostButton)
        activityStackView.addArrangedSubview(blockedUsersButton)
        
        view.addSubview(accountStackView)
        accountStackView.addArrangedSubview(accountLabel)
        accountStackView.addArrangedSubview(logoutButton)
        accountStackView.addArrangedSubview(deleteAccountButton)
    }
    
    func setConstraints() {
                
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6),
            profileImageView.widthAnchor.constraint(equalToConstant: 96),
            profileImageView.heightAnchor.constraint(equalToConstant: 96)
        ])
        
        NSLayoutConstraint.activate([
            profileStackView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 15),
            profileStackView.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor, constant: 0)
        ])
        
        NSLayoutConstraint.activate([
            activityStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            activityStackView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 35),
            activityStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            accountStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            accountStackView.topAnchor.constraint(equalTo: activityStackView.bottomAnchor, constant: 40),
            accountStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])

    }
    
    func bindViewModel() {
        let output = viewModel.transform(input: Input(
            logoutSubject: logoutSubject.eraseToAnyPublisher(),
            deleteAccountSubject: deleteAccountSubject.eraseToAnyPublisher()
        ))
        
        output.logoutSucceed
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    dump("Failed logout: \(error)")
                }
            } receiveValue: {
                NotificationCenter.default.post(Notification(name: .shouldLogin))
            }
            .store(in: &cancellableBag)
        
        output.deleteAccountSucceed
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    dump("Failed delete account: \(error)")
                }
            } receiveValue: {
                NotificationCenter.default.post(Notification(name: .shouldLogin))
            }
            .store(in: &cancellableBag)
        
        output.profileInfoOutput
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profileInfo in
                guard let data = profileInfo?.profileImage,
                      let image = UIImage(data: data) else { return }
                self?.profileImageView.image = image
                self?.nicknameLabel.text = profileInfo?.nickname
                guard let userID = JWTManager.shared.currentUserID else { return }
                self?.hashIDLabel.text = "#" + userID
            }
            .store(in: &cancellableBag)
    }
    
}

@objc
private extension MyPageViewController {
    
    func profileEditButtonTapped() {
        guard let postInfo = viewModel.profileInfoSubject.value else { return }
        let nextVC = SignUpViewController(viewModel: SignUpViewModel(
            profileInfo: postInfo
        ))
        nextVC.hidesBottomBarWhenPushed = true
        nextVC.updateSuccessSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.viewModel.getUserInfo()
            }
            .store(in: &cancellableBag)
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func myPostsButtonTapped() {
        let nextVC = MyPostsViewController(viewModel: MyPostsViewModel())
        nextVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func hiddenPostButtonTapped() {
        let nextVC = MyHiddenPostsViewController(viewModel: MyHiddenPostsViewModel())
        nextVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func blockedUsersButtonTapped() {
        let nextVC = BlockedUserViewController(viewModel: BlockedUsersViewModel())
        nextVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func logoutButtonTapped() {
        let alert = UIAlertController(title: "로그아웃", message: "정말 로그아웃하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "로그아웃", style: .default, handler: { [weak self] _ in
            self?.logoutSubject.send()
        }))
        self.present(alert, animated: true)
    }
    
    func deleteAccountButtonTapped() {
        let alert = UIAlertController(title: "회원탈퇴", message: "회원탈퇴 시 모든 정보가 삭제됩니다!\n진행하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "탈퇴하기", style: .destructive, handler: { [weak self] _ in
            self?.deleteAccountSubject.send()
        }))
        self.present(alert, animated: true)
    }
    
}
