//
//  PostMuteTableViewCell.swift
//  Village
//
//  Created by 박동재 on 2023/12/04.
//

import UIKit

final class PostMuteTableViewCell: UITableViewCell {
    
    private let postView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 16
        
        return imageView
    }()
    
    private let postTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .bold)
        
        return label
    }()
    
    private var postMuteButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.titleAlignment = .center
        configuration.baseBackgroundColor = .primary500
        var titleAttribute = AttributedString.init("숨김 해제")
        titleAttribute.font = .systemFont(ofSize: 12.0, weight: .bold)
        configuration.attributedTitle = titleAttribute
        
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    func configureData(post: PostMuteResponseDTO) {
        postTitleLabel.text = post.title
        
        configureImage(url: post.images.first ?? "")
    }
    
    func configureImage(url: String) {
        Task {
            do {
                let data = try await APIProvider.shared.request(from: url)
                postImageView.image = UIImage(data: data)
            } catch let error {
                dump(error)
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("should not be called")
    }
    
    private func configureUI() {
        postView.addSubview(postImageView)
        postView.addSubview(postTitleLabel)
        postView.addSubview(postMuteButton)
        self.contentView.addSubview(postView)
        
        configureConstraints()
    }
    
    private func configureConstraints() {
        
        NSLayoutConstraint.activate([
            postView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            postView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            postView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            postView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        NSLayoutConstraint.activate([
            postImageView.topAnchor.constraint(equalTo: postView.topAnchor, constant: 10),
            postImageView.leadingAnchor.constraint(equalTo: postView.leadingAnchor, constant: 10),
            postImageView.widthAnchor.constraint(equalToConstant: 60),
            postImageView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        NSLayoutConstraint.activate([
            postTitleLabel.centerYAnchor.constraint(equalTo: postView.centerYAnchor),
            postTitleLabel.leadingAnchor.constraint(equalTo: postImageView.trailingAnchor, constant: 20),
            postTitleLabel.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        NSLayoutConstraint.activate([
            postMuteButton.topAnchor.constraint(equalTo: postView.topAnchor, constant: 25),
            postMuteButton.trailingAnchor.constraint(equalTo: postView.trailingAnchor, constant: -20),
            postMuteButton.widthAnchor.constraint(equalToConstant: 80),
            postMuteButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
}
