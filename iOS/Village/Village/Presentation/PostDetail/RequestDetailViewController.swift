//
//  RequestDetailViewController.swift
//  Village
//
//  Created by 정상윤 on 11/22/23.
//

import UIKit

final class RequestDetailViewController: UIViewController {
    
    private let post: Post
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        return scrollView
    }()
    
    private var containerView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 10
        stackView.axis = .vertical
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
    
    private var chatButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .primary500
        let title = NSAttributedString(string: "채팅하기",
                                       attributes: [.font: UIFont.boldSystemFont(ofSize: 16),
                                                    .foregroundColor: UIColor.white])
        button.setAttributedTitle(title, for: .normal)
        button.layer.cornerRadius = 6
        return button
    }()
    
    init(post: Post) {
        self.post = post
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder: NSCoder) {
        fatalError("Should not be called")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureNavigationItem()
        setLayoutConstraints()
        setContent()
    }
    
    @objc
    private func moreBarButtonTapped() {
        // TODO: 더보기 버튼 기능 구현
    }
    
}

private extension RequestDetailViewController {
    
    func configureUI() {
        view.backgroundColor = .systemBackground
        tabBarController?.tabBar.isHidden = true
        
        view.addSubview(scrollView)
        view.addSubview(footerView)
        scrollView.addSubview(containerView)
        containerView.addArrangedSubview(userInfoView)
        containerView.addArrangedSubview(UIView.divider(.horizontal))
        containerView.addArrangedSubview(postInfoView)
        footerView.addSubview(chatButton)
    }
    
    func setContent() {
        postInfoView.setContent(title: post.title,
                                startDate: post.startDate, endDate: post.endDate,
                                description: post.contents)
        let dummyURL = "https://img.gqkorea.co.kr/gq/2022/08/style_63073140eea70.jpg"
        userInfoView.setContent(imageURL: dummyURL, nickname: "이지금 [IU Official]")
    }
    
    func configureNavigationItem() {
        let rightBarButton = UIBarButtonItem(image: UIImage(systemName: ImageSystemName.ellipsis.rawValue),
                                             style: .plain,
                                             target: self,
                                             action: #selector(moreBarButtonTapped))
        
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func setLayoutConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: footerView.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 15),
            containerView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -15),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            footerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            chatButton.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            chatButton.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),
            chatButton.widthAnchor.constraint(equalTo: footerView.widthAnchor, multiplier: 0.8),
            chatButton.heightAnchor.constraint(equalTo: footerView.heightAnchor, multiplier: 0.7)
        ])
    }
    
}
