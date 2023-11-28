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
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.setLayer()
        
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
        setConstraints()
    }

}

private extension ChatRoomCollectionViewCell {
    
    func setUI() {
        addSubview(messageView)
        addSubview(profileImageView)
    }
    
    func setConstraints() {
        if messageView.frame.width > frame.width - 54 {
            let newSize = messageView.sizeThatFits(CGSize(width: Int(frame.width) - 54, height: Int.max))
            messageView.frame.size = CGSize(width: newSize.width, height: newSize.height)
        }
        
        NSLayoutConstraint.activate([
            profileImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            profileImageView.widthAnchor.constraint(equalToConstant: 24),
            profileImageView.heightAnchor.constraint(equalToConstant: 24),
            messageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            messageView.widthAnchor.constraint(equalToConstant: messageView.frame.width),
            messageView.heightAnchor.constraint(equalToConstant: messageView.frame.height)
        ])
        
        NSLayoutConstraint.activate([
            profileImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            messageView.trailingAnchor.constraint(equalTo: profileImageView.leadingAnchor, constant: -10)
        ])
    }
    
}
