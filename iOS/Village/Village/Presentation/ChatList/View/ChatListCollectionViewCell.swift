//
//  ChatListCollectionViewCell.swift
//  Village
//
//  Created by 박동재 on 2023/11/23.
//

import UIKit

class ChatListCollectionViewCell: UICollectionViewCell {
    
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("Should not be called")
    }

}
