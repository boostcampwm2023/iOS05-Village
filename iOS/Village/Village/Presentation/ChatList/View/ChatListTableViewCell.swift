//
//  ChatListTableViewCell.swift
//  Village
//
//  Created by 박동재 on 2023/12/02.
//

import UIKit

class ChatListTableViewCell: UITableViewCell {

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
        label.textColor = .systemGray3
        
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            recentTimeLabel.trailingAnchor.constraint(equalTo: postImageView.leadingAnchor, constant: -10)
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
    
    func configureData(data: GetChatListResponseDTO) async {
        nicknameLabel.text = data.user != JWTManager.shared.currentUserID
        ? data.userNickname
        : data.writerNickname

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'.000Z'"
        
        let currentData = Date()
        
        guard let lastChatDate = data.lastChatDate,
              let lastChat = data.lastChat
        else { return }

        if let date = dateFormatter.date(from: lastChatDate) {
            let timeInterval = currentData.timeIntervalSince(date)
            let minuteInterval = Int(timeInterval/60)

            if minuteInterval >= 60 * 24 {
                dateFormatter.dateFormat = "yy.MM.dd"
                let formattedDate = dateFormatter.string(from: date)
                let formattedCurrentDate = dateFormatter.string(from: currentData)

                if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: currentData),
                    formattedDate == dateFormatter.string(from: yesterday) {
                    recentTimeLabel.text = "어제"
                } else {
                    recentTimeLabel.text = "\(formattedDate)"
                }
            } else if minuteInterval >= 60 {
                recentTimeLabel.text = "\(minuteInterval / 60)시간전"
            } else {
                recentTimeLabel.text = "\(minuteInterval)분전"
            }
        }
        
        recentChatLabel.text = lastChat.count > 10 ? String(lastChat.prefix(10)) + "..." : lastChat
        await configureUserProfile(data.userProfileIMG)
        await configurePostImage(data.postThumbnail)
    }
    
    func configureUserProfile(_ url: String?) async {
        if let url = url {
            do {
                let data = try await APIProvider.shared.request(from: url)
                profileImageView.image = UIImage(data: data)
            } catch {
                dump(error)
            }
        } else {
            profileImageView.image = UIImage(systemName: ImageSystemName.photo.rawValue)
            profileImageView.backgroundColor = .primary100
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
            postImageView.image = UIImage(systemName: ImageSystemName.photo.rawValue)
            postImageView.backgroundColor = .primary100
        }
    }

}
