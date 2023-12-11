//
//  RequstPostTableViewCell.swift
//  Village
//
//  Created by 조성민 on 12/5/23.
//

import UIKit

final class RequestPostTableViewCell: UITableViewCell {

    private let postSummaryView: RequestPostSummaryView = {
        let view = RequestPostSummaryView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(postSummaryView)
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postSummaryView.postPeriodLabel.text = nil
        postSummaryView.postTitleLabel.text = nil
    }
    
    func configureData(post: PostListResponseDTO) {
        postSummaryView.postTitleLabel.text = post.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        guard let startTimeDate = dateFormatter.date(from: post.startDate),
        let endTimeDate = dateFormatter.date(from: post.endDate) else { return }
        dateFormatter.dateFormat = "yyyy.MM.dd. HH시"
        let startTime = dateFormatter.string(from: startTimeDate)
        let endTime = dateFormatter.string(from: endTimeDate)
        
        postSummaryView.postPeriodLabel.text = startTime + " ~ " + endTime
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            postSummaryView.topAnchor.constraint(equalTo: contentView.topAnchor),
            postSummaryView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            postSummaryView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            postSummaryView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
}
