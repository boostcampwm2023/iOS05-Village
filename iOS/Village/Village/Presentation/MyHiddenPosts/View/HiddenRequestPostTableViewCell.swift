//
//  HiddenRequestPostTableViewCell.swift
//  Village
//
//  Created by 조성민 on 12/9/23.
//

import UIKit
import Combine

class HiddenRequestPostTableViewCell: UITableViewCell {
    
    let hideToggleSubject = PassthroughSubject<Bool, Never>()
    
    let postTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .bold)
        
        return label
    }()
    
    let postPeriodLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .regular)
        
        return label
    }()
    
    private lazy var postMuteButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.titleAlignment = .center
        configuration.baseBackgroundColor = .primary500
        var titleAttribute = AttributedString.init("숨김 해제")
        titleAttribute.font = .systemFont(ofSize: 12.0, weight: .bold)
        configuration.attributedTitle = titleAttribute
        
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(target, action: #selector(muteButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private let hideOnString: AttributedString = {
        var titleAttribute = AttributedString.init("숨기기")
        titleAttribute.font = .systemFont(ofSize: 12.0, weight: .bold)
        return titleAttribute
    }()
    
    private let hideOffString: AttributedString = {
        var titleAttribute = AttributedString.init("숨김 해제")
        titleAttribute.font = .systemFont(ofSize: 12.0, weight: .bold)
        return titleAttribute
    }()
    
    @objc private func muteButtonTapped() {
        if postMuteButton.titleLabel?.text == "숨김 해제" {
            postMuteButton.configuration?.baseBackgroundColor = .black
            postMuteButton.configuration?.attributedTitle = hideOnString
            hideToggleSubject.send(false)
        } else {
            postMuteButton.configuration?.baseBackgroundColor = .primary500
            postMuteButton.configuration?.attributedTitle = hideOffString
            hideToggleSubject.send(true)
        }
    }
    
    func configureData(post: PostMuteResponseDTO) {
        postTitleLabel.text = post.title
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        guard let startDate = dateFormatter.date(from: post.startDate),
              let endDate = dateFormatter.date(from: post.endDate) else { return }
        dateFormatter.dateFormat = "yyyy.MM.dd HH시"
        let startDateString = dateFormatter.string(from: startDate)
        let endDateString = dateFormatter.string(from: endDate)
        postPeriodLabel.text = startDateString + " ~ " + endDateString
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("should not be called")
    }
    
    private func configureUI() {
        contentView.addSubview(postTitleLabel)
        contentView.addSubview(postPeriodLabel)
        contentView.addSubview(postMuteButton)
    }
    
    private func configureConstraints() {
        
        NSLayoutConstraint.activate([
            postTitleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -15),
            postTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            postTitleLabel.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        NSLayoutConstraint.activate([
            postPeriodLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 15),
            postPeriodLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30)
        ])
        
        NSLayoutConstraint.activate([
            postMuteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            postMuteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }

}
