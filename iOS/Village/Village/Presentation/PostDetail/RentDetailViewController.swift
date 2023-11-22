//
//  RentDetailViewController.swift
//  Village
//
//  Created by 박동재 on 2023/11/17.
//

import UIKit

final class RentDetailViewController: UIViewController {
    
    private var post: Post
    
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
    
    private var postInfoContainerView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 10
        stackView.axis = .vertical
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return stackView
    }()
    
    private var imagePageView: ImagePageView = {
        let imagePageView = ImagePageView()
        imagePageView.translatesAutoresizingMaskIntoConstraints = false
        return imagePageView
    }()
    
    private var userInfoContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 70).isActive = true
        return view
    }()
    
    private var userProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.setLayer(borderColor: .grey100, cornerRadius: 26)
        return imageView
    }()
    
    private var userNicknameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    private var postLabelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 20
        stackView.axis = .vertical
        return stackView
    }()
    
    private var postTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 20)
        label.numberOfLines = 0
        return label
    }()
    
    private var postDurationView: DurationView = {
        let durationView = DurationView()
        durationView.translatesAutoresizingMaskIntoConstraints = false
        durationView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return durationView
    }()
    
    private var postContentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    private var footerView: UIView = {
        let view = UIView()
        let divider = UIView.divider(.horizontal)
        view.addSubview(divider)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 65).isActive = true
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
        button.widthAnchor.constraint(equalToConstant: 110).isActive = true
        button.heightAnchor.constraint(equalToConstant: 35).isActive = true
        return button
    }()
    
    init(postData: Post) {
        self.post = postData
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Should not be called")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    @objc
    private func moreBarButtonTapped() {
        // TODO: 더보기 버튼 기능 구현
    }

}

private extension RentDetailViewController {
    
    func configureUI() {
        view.backgroundColor = .systemBackground
        tabBarController?.tabBar.isHidden = true
        
        view.addSubview(scrollView)
        view.addSubview(footerView)
        scrollView.addSubview(scrollViewContainerView)
        
        configureNavigationItem()
        configureScrollView()
        setContents()
        setLayoutConstraints()
    }
    
    func configureNavigationItem() {
        let rightBarButton = UIBarButtonItem(image: UIImage(systemName: ImageSystemName.ellipsis.rawValue),
                                             style: .plain,
                                             target: self,
                                             action: #selector(moreBarButtonTapped))
        
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func configureScrollView() {
        scrollViewContainerView.addArrangedSubview(imagePageView)
        scrollViewContainerView.addArrangedSubview(postInfoContainerView)
        postInfoContainerView.addArrangedSubview(userInfoContainerView)
        userInfoContainerView.addSubview(userProfileImageView)
        userInfoContainerView.addSubview(userNicknameLabel)
        postInfoContainerView.addArrangedSubview(UIView.divider(.horizontal, width: 0.5))
        postInfoContainerView.addArrangedSubview(postLabelStackView)
        postLabelStackView.addArrangedSubview(postTitleLabel)
        postLabelStackView.addArrangedSubview(postDurationView)
        postLabelStackView.addArrangedSubview(postContentLabel)
        footerView.addSubview(priceLabel)
        footerView.addSubview(chatButton)
    }
    
    func setContents() {
        setUserInfoContents()
        setPostInfoContents()
    }
    
    func setUserInfoContents() {
        if post.images.isEmpty {
            imagePageView.isHidden = true
        } else {
            Task {
                do {
                    let dummyURL = "https://img.gqkorea.co.kr/gq/2022/08/style_63073140eea70.jpg"
                    let data = try await NetworkService.loadData(from: dummyURL)
                    userProfileImageView.image = UIImage(data: data)
                } catch let error {
                    dump(error)
                }
            }
        }
        
        userNicknameLabel.text = "이지금 [IU Official]"
    }
    
    func setPostInfoContents() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        imagePageView.setImageURL(post.images)
        postTitleLabel.text = post.title
        postDurationView.setDuration(from: dateFormatter.date(from: post.startDate)!,
                                     to: dateFormatter.date(from: post.startDate)!)
        setPostConetentsLabel()
        priceLabel.setPrice(price: post.price)
    }
    
    func setPostConetentsLabel() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 7
        
        let attributedText = NSAttributedString(
            string: post.contents,
            attributes: [
                .font: UIFont.systemFont(ofSize: 17),
                .paragraphStyle: paragraphStyle
        ])
        
        postContentLabel.attributedText = attributedText
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
            userProfileImageView.centerYAnchor.constraint(equalTo: userInfoContainerView.centerYAnchor),
            userProfileImageView.leadingAnchor.constraint(equalTo: userInfoContainerView.leadingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            userNicknameLabel.leadingAnchor.constraint(equalTo: userProfileImageView.trailingAnchor, constant: 15),
            userNicknameLabel.centerYAnchor.constraint(equalTo: userInfoContainerView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            footerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            chatButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -25),
            chatButton.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),
            priceLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 25),
            priceLabel.trailingAnchor.constraint(lessThanOrEqualTo: chatButton.leadingAnchor, constant: -10),
            priceLabel.centerYAnchor.constraint(equalTo: chatButton.centerYAnchor)
        ])
    }
    
}
