//
//  ChatRoomCollectionViewCell.swift
//  Village
//
//  Created by 박동재 on 2023/11/27.
//

import UIKit

class ChatRoomCollectionViewCell: UICollectionViewCell {
    
    private let messageView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        return textView
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hideProfile() {
        profileImageView.isHidden = true
    }
    
    func configureData(message: String, profileImageURL: String) {
        messageView.text = message
        messageView.sizeToFit()
        Task {
            do {
                let data = try await NetworkService.loadData(from: profileImageURL)
                
                profileImageView.image = UIImage(data: data)
                
            } catch let error {
                dump(error)
            }
        }
    }

}

private extension ChatRoomCollectionViewCell {
    
    func setUI() {
        addSubview(messageView)
        addSubview(profileImageView)
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0),
            profileImageView.widthAnchor.constraint(equalToConstant: 24),
            profileImageView.heightAnchor.constraint(equalToConstant: 24),
            messageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0)
        ])
        NSLayoutConstraint.activate([
            profileImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            messageView.trailingAnchor.constraint(equalTo: profileImageView.leadingAnchor, constant: -10),
            messageView.widthAnchor.constraint(equalToConstant: 100),
            messageView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
}
