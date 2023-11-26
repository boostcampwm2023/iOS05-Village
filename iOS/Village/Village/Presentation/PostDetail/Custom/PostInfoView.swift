//
//  PostInfoView.swift
//  Village
//
//  Created by 정상윤 on 11/23/23.
//

import UIKit

final class PostInfoView: UIView {

    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 20
        stackView.axis = .vertical
        return stackView
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 20)
        label.numberOfLines = 0
        return label
    }()
    
    private var durationView: DurationView = {
        let durationView = DurationView()
        durationView.translatesAutoresizingMaskIntoConstraints = false
        durationView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return durationView
    }()
    
    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
        setLayoutConstraints()
    }
    
    required init(coder: NSCoder) {
        fatalError("Should not be called")
    }
    
    func setContent(title: String, startDate: String, endDate: String, description: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        titleLabel.text = title
        if let start = dateFormatter.date(from: startDate),
           let end = dateFormatter.date(from: endDate) {
            durationView.setDuration(from: start, to: end)
        }
        setDescriptionLabel(description)
    }
    
    private func setDescriptionLabel(_ description: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 7

        let attributedText = NSAttributedString(
            string: description,
            attributes: [
                .font: UIFont.systemFont(ofSize: 17),
                .paragraphStyle: paragraphStyle
        ])
        
        descriptionLabel.attributedText = attributedText
    }

}

private extension PostInfoView {
    
    func configureUI() {
        addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(durationView)
        stackView.addArrangedSubview(descriptionLabel)
    }
    
    func setLayoutConstraints() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
}
