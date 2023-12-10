//
//  RequestPostSummaryView.swift
//  Village
//
//  Created by 조성민 on 12/6/23.
//

import UIKit

final class RequestPostSummaryView: UIView {
    
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
    
    let postAccessoryView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: ImageSystemName.chevronRight.rawValue)
        imageView.tintColor = .primary500
        
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUI()
    }
    
    func configureData(post: PostResponseDTO) {
        postTitleLabel.text = post.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        guard let startTimeDate = dateFormatter.date(from: post.startDate),
        let endTimeDate = dateFormatter.date(from: post.endDate) else { return }
        dateFormatter.dateFormat = "yyyy.MM.dd. HH시"
        let startTime = dateFormatter.string(from: startTimeDate)
        let endTime = dateFormatter.string(from: endTimeDate)
        
        postPeriodLabel.text = startTime + " ~ " + endTime
    }
    
    private func setUI() {
        addSubview(postTitleLabel)
        addSubview(postPeriodLabel)
        addSubview(postAccessoryView)
        
        configureConstraints()
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            postTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -15),
            postTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            postTitleLabel.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        NSLayoutConstraint.activate([
            postPeriodLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 15),
            postPeriodLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30)
        ])
        
        NSLayoutConstraint.activate([
            postAccessoryView.centerYAnchor.constraint(equalTo: centerYAnchor),
            postAccessoryView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }
}
