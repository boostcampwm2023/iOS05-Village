//
//  OpponentChatTableViewCell.swift
//  Village
//
//  Created by 박동재 on 12/8/23.
//

import UIKit

final class OpponentChatTableViewCell: UITableViewCell {
    
    private let messageView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.setLayer(borderWidth: 0)
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.textColor = .white
        textView.sizeToFit()
        textView.backgroundColor = .userChatMessage
        
        return textView
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        profileImageView.image = nil
        messageView.text = nil
    }
    
    func configureData(message: String) {
        messageView.text = message
        messageView.sizeToFit()
    }
    
    func configureImage(image: Data) {
        profileImageView.image = UIImage(data: image)
    }

}

private extension OpponentChatTableViewCell {
    
    func setUI() {
        contentView.addSubview(messageView)
        contentView.addSubview(profileImageView)
        
        setConstraints()
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            profileImageView.widthAnchor.constraint(equalToConstant: 24),
            profileImageView.heightAnchor.constraint(equalToConstant: 24),
            messageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            messageView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            messageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            messageView.widthAnchor.constraint(lessThanOrEqualToConstant: 255)
        ])
    }
    
}
