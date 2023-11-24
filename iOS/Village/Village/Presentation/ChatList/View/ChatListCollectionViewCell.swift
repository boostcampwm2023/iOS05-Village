//
//  ChatListCollectionViewCell.swift
//  Village
//
//  Created by 박동재 on 2023/11/23.
//

import UIKit

class ChatListCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "ChatListCollectionViewCell"
    
    private let chatView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 24
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private let nicknameLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .bold)
        
        return label
    }()
    
    private let recentTimeLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        
        return label
    }()
    
    private let recentChatLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .regular)
        
        return label
    }()
    
    private let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 16
        
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Should not be called")
    }

    private func configureUI() {
        self.addSubview(chatView)
        chatView.addSubview(profileImageView)
        chatView.addSubview(nicknameLabel)
        chatView.addSubview(recentTimeLabel)
        chatView.addSubview(recentChatLabel)
        chatView.addSubview(postImageView)
        
        configureConstraints()
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            chatView.topAnchor.constraint(equalTo: self.topAnchor),
            chatView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            chatView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            chatView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: chatView.topAnchor, constant: 16),
            profileImageView.leadingAnchor.constraint(equalTo: chatView.leadingAnchor, constant: 16),
            profileImageView.widthAnchor.constraint(equalToConstant: 48),
            profileImageView.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        NSLayoutConstraint.activate([
            nicknameLabel.topAnchor.constraint(equalTo: chatView.topAnchor, constant: 16),
            nicknameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 20),
            nicknameLabel.widthAnchor.constraint(equalToConstant: 80)
        ])
        
        NSLayoutConstraint.activate([
            recentTimeLabel.topAnchor.constraint(equalTo: chatView.topAnchor, constant: 16),
            recentTimeLabel.leadingAnchor.constraint(equalTo: nicknameLabel.trailingAnchor, constant: 4)
        ])
        
        NSLayoutConstraint.activate([
            recentChatLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 10),
            recentChatLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 20)
        ])
        
        NSLayoutConstraint.activate([
            postImageView.topAnchor.constraint(equalTo: chatView.topAnchor, constant: 10),
            postImageView.trailingAnchor.constraint(equalTo: chatView.trailingAnchor, constant: -15),
            postImageView.widthAnchor.constraint(equalToConstant: 60),
            postImageView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
//    func configureData(data: PostResponseDTO) {
//        nicknameLabel.text = String(data.userId)
//        recentTimeLabel.text = data.endDate
//        recentChatLabel.text = data.contents.count > 10 ? String(data.contents.prefix(10)) + "..." : data.contents
//    }
    
    func configureImage(image: UIImage?) {
        if image != nil {
            postImageView.image = image
            profileImageView.image = image
        } else {
            postImageView.image = UIImage(systemName: ImageSystemName.photo.rawValue)?.withTintColor(
                .primary500, renderingMode: .alwaysOriginal
            )
            postImageView.backgroundColor = .primary100
            profileImageView.image = UIImage(systemName: ImageSystemName.personFill.rawValue)?.withTintColor(
                .primary500, renderingMode: .alwaysOriginal
            )
            profileImageView.backgroundColor = .primary100
        }
    }
    
}
