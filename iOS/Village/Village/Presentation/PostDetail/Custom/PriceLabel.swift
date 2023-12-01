//
//  PriceLabel.swift
//  Village
//
//  Created by 정상윤 on 11/22/23.
//

import UIKit

final class PriceLabel: UIView {

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 10
        return stackView
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    
    private let unitLabel: UILabel = {
        let label = UILabel()
        label.text = "시간당"
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("Should not be implemented")
    }
    
    func setPrice(price: Int?) {
        guard let price = price else { return }
        let priceText = price.priceText()
        priceLabel.text = "\(priceText)원"
    }
    
    private func configureUI() {
        addSubview(stackView)
        stackView.addArrangedSubview(unitLabel)
        stackView.addArrangedSubview(priceLabel)
        
        setLayoutConstaints()
    }
    
    private func setLayoutConstaints() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
}
