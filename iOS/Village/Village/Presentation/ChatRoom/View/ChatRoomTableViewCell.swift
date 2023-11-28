//
//  ChatRoomTableViewCell.swift
//  Village
//
//  Created by 조성민 on 11/28/23.
//

import UIKit

final class ChatRoomTableViewCell: UITableViewCell {
    
    private let messageView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.setLayer(borderWidth: 0)
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.textColor = .white
        
        return textView
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hideProfile() {
        profileImageView.isHidden = true
    }
    
    func configureData(message: String, profileImageURL: String, isMine: Bool) {
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
        setConstraints(isMine: isMine)
    }

}

private extension ChatRoomTableViewCell {
    
    func setUI() {
        contentView.addSubview(messageView)
        contentView.addSubview(profileImageView)
    }
    
    func setConstraints(isMine: Bool) {
        if messageView.frame.width > frame.width {
            let newSize = messageView.sizeThatFits(CGSize(width: Int(bounds.width), height: Int.max))
            messageView.frame.size = CGSize(width: newSize.width, height: newSize.height)
        }
        
        NSLayoutConstraint.activate([
            profileImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            profileImageView.widthAnchor.constraint(equalToConstant: 24),
            profileImageView.heightAnchor.constraint(equalToConstant: 24),
            messageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            messageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            messageView.widthAnchor.constraint(equalToConstant: messageView.frame.width)
        ])
        
        if isMine {
            messageView.backgroundColor = .myChatMessage
            NSLayoutConstraint.activate([
                profileImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
                messageView.trailingAnchor.constraint(equalTo: profileImageView.leadingAnchor, constant: -10)
            ])
        } else {
            messageView.backgroundColor = .userChatMessage
            NSLayoutConstraint.activate([
                profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
                messageView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10)
            ])
        }
    }
    
}
