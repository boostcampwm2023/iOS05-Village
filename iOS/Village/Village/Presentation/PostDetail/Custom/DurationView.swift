//
//  DurationView.swift
//  Village
//
//  Created by 정상윤 on 11/21/23.
//

import UIKit

final class DurationView: UIView {
    
    private var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return stackView
    }()
    
    private var startDateView = DateView()
    private var divider = UIView.divider(.vertical)
    private var endDateView = DateView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setLayer(borderWidth: 1, borderColor: .grey100)
        configureUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("Should not be called")
    }
    
    func setDuration(from startDate: Date, to endDate: Date) {
        startDateView.setLabelText(title: "시작", date: startDate)
        endDateView.setLabelText(title: "반납", date: endDate)
    }
    
    private func configureUI() {
        addSubview(containerStackView)
        containerStackView.addArrangedSubview(startDateView)
        containerStackView.addArrangedSubview(divider)
        containerStackView.addArrangedSubview(endDateView)
        
        setLayoutConstraints()
    }
    
    private func setLayoutConstraints() {
        startDateView.translatesAutoresizingMaskIntoConstraints = false
        endDateView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerStackView.topAnchor.constraint(equalTo: topAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            divider.heightAnchor.constraint(equalTo: heightAnchor)
        ])
    }
    
}
