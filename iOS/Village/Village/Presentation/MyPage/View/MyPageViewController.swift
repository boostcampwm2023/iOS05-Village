//
//  MyPageViewController.swift
//  Village
//
//  Created by 박동재 on 2023/11/18.
//

import UIKit
import Combine

final class MyPageViewController: UIViewController {
    
    private let viewModel: MyPageViewModel
    private var cancellableBag: Set<AnyCancellable> = []
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: ImageSystemName.personFill.rawValue)
        imageView.tintColor = .primary500
        imageView.setLayer(borderWidth: 0, cornerRadius: 16)
        imageView.backgroundColor = .primary100
        
        return imageView
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.text = "닉네임"
        
        return label
    }()
    
    private let hashIDLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "#123123"
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
    
    private lazy var hiddenUserButton: UIButton = {
        var titleAttr = AttributedString.init("차단 관리")
        titleAttr.font = .systemFont(ofSize: 16, weight: .bold)
        
        var configuration = UIButton.Configuration.plain()
        configuration.baseForegroundColor = .label
        configuration.attributedTitle = titleAttr
        configuration.buttonSize = .medium
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(hiddenUserButtonTapped), for: .touchUpInside)
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
        view.addSubview(nicknameLabel)
        view.addSubview(hashIDLabel)
        view.addSubview(profileEditButton)
        view.addSubview(activityStackView)
        view.addSubview(accountStackView)
        
        activityStackView.addArrangedSubview(activityLabel)
        activityStackView.addArrangedSubview(myPostButton)
        activityStackView.addArrangedSubview(hiddenPostButton)
        activityStackView.addArrangedSubview(hiddenUserButton)
        
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
            nicknameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 15),
            nicknameLabel.bottomAnchor.constraint(equalTo: profileImageView.centerYAnchor, constant: -5)
        ])
        
        NSLayoutConstraint.activate([
            hashIDLabel.leadingAnchor.constraint(equalTo: nicknameLabel.trailingAnchor, constant: 5),
            hashIDLabel.bottomAnchor.constraint(equalTo: nicknameLabel.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            profileEditButton.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 15),
            profileEditButton.topAnchor.constraint(equalTo: profileImageView.centerYAnchor, constant: 5)
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
        
    }
    
}

@objc
private extension MyPageViewController {
    
    func profileEditButtonTapped() {
        
    }
    
    func myPostsButtonTapped() {
        let nextVC = MyPostsViewController(viewModel: MyPostsViewModel())
        nextVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func hiddenPostButtonTapped() {
        let nextVC = PostMuteViewController()
        nextVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func hiddenUserButtonTapped() {
        let nextVC = BannedUserViewController()
        nextVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func logoutButtonTapped() {
        
    }
    
    func deleteAccountButtonTapped() {
        
    }
    
}
