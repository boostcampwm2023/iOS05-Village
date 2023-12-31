//
//  ChatListTableViewCell.swift
//  Village
//
//  Created by 박동재 on 2023/12/02.
//

import UIKit

class ChatListTableViewCell: UITableViewCell {
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 24
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private lazy var nicknameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .bold)
        
        return label
    }()
    
    private lazy var recentTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .systemGray3
        
        return label
    }()
    
    private lazy var recentChatLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .regular)
        
        return label
    }()
    
    private lazy var isReadLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        label.layer.cornerRadius = 4
        
        return label
    }()
    
    private lazy var postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        profileImageView.image = nil
        nicknameLabel.text = nil
        recentTimeLabel.text = nil
        recentChatLabel.text = nil
        isReadLabel.text = nil
        postImageView.image = nil
    }

    private func configureUI() {
        self.contentView.addSubview(profileImageView)
        self.contentView.addSubview(nicknameLabel)
        self.contentView.addSubview(recentTimeLabel)
        self.contentView.addSubview(recentChatLabel)
        self.contentView.addSubview(isReadLabel)
        self.contentView.addSubview(postImageView)
        
        configureConstraints()
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 16),
            profileImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            profileImageView.widthAnchor.constraint(equalToConstant: 48),
            profileImageView.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        NSLayoutConstraint.activate([
            nicknameLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 16),
            nicknameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 20)
        ])
        
        NSLayoutConstraint.activate([
            recentTimeLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 17),
            recentTimeLabel.leadingAnchor.constraint(equalTo: nicknameLabel.trailingAnchor, constant: 10)
        ])
        
        NSLayoutConstraint.activate([
            recentChatLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -20),
            recentChatLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 20)
        ])
        
        NSLayoutConstraint.activate([
            isReadLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 20),
            isReadLabel.leadingAnchor.constraint(equalTo: recentTimeLabel.trailingAnchor, constant: 6),
            isReadLabel.widthAnchor.constraint(equalToConstant: 8),
            isReadLabel.heightAnchor.constraint(equalToConstant: 8)
        ])
        
        NSLayoutConstraint.activate([
            postImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10),
            postImageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15),
            postImageView.widthAnchor.constraint(equalToConstant: 60),
            postImageView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func configureData(data: ChatListData) async {
        nicknameLabel.text = data.user != JWTManager.shared.currentUserID
        ? data.userNickname
        : data.writerNickname
        nicknameLabel.sizeToFit()
        
        if data.user != JWTManager.shared.currentUserID {
            await configureUserProfile(data.userProfileIMG)
        } else {
            await configureUserProfile(data.writerProfileIMG)
        }
        await configurePostImage(data.postThumbnail)
        
        guard let lastChatDate = data.lastChatDate,
              let lastChat = data.lastChat
        else { return }
        setLastChatDate(date: lastChatDate)
        recentChatLabel.text = lastChat.count > 10 ? String(lastChat.prefix(10)) + "..." : lastChat
        
        if data.allRead == true {
            isReadLabel.text = nil
            isReadLabel.layer.backgroundColor = nil
        } else {
            isReadLabel.text = " "
            isReadLabel.layer.backgroundColor = UIColor.alert.cgColor
        }
    }
    
    private func setLastChatDate(date: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'.000Z'"
        
        let currentData = Date()
        
        if let date = dateFormatter.date(from: date) {
            let timeInterval = currentData.timeIntervalSince(date)
            let minuteInterval = Int(timeInterval/60) - 540
            if minuteInterval >= 60 * 24 {
                dateFormatter.dateFormat = "yy.MM.dd"
                let formattedDate = dateFormatter.string(from: date)
                
                if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: currentData),
                   formattedDate == dateFormatter.string(from: yesterday) {
                    recentTimeLabel.text = "어제"
                } else {
                    recentTimeLabel.text = "\(formattedDate)"
                }
            } else if minuteInterval >= 60 {
                recentTimeLabel.text = "\(minuteInterval / 60)시간전"
            } else if minuteInterval >= 1 {
                recentTimeLabel.text = "\(minuteInterval)분전"
            } else {
                recentTimeLabel.text = "방금"
            }
        }
    }
    
    func configureUserProfile(_ url: String?) async {
        if let url = url {
            do {
                let data = try await APIProvider.shared.request(from: url)
                profileImageView.image = UIImage(data: data)
            } catch {
                dump(error)
            }
        }
    }
    
    func configurePostImage(_ url: String?) async {
        if let url = url {
            do {
                let data = try await APIProvider.shared.request(from: url)
                postImageView.image = UIImage(data: data)
            } catch {
                dump(error)
            }
        } else {
            postImageView.image = nil
            postImageView.backgroundColor = nil
        }
    }

}
