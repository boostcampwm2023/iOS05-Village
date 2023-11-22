//
//  DateView.swift
//  Village
//
//  Created by 정상윤 on 11/21/23.
//

import UIKit

final class DateView: UIView {
    
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 17, weight: .bold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("Should not be called")
    }
    
    func setLabelText(title: String, date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH시"
        titleLabel.text = title
        dateLabel.text = dateFormatter.string(from: date)
    }
    
    private func configureUI() {
        addSubview(containerStackView)
        containerStackView.addArrangedSubview(titleLabel)
        containerStackView.addArrangedSubview(dateLabel)
        
        setLayoutConstraints()
    }
    
    private func setLayoutConstraints() {
        NSLayoutConstraint.activate([
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerStackView.topAnchor.constraint(equalTo: topAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
}
