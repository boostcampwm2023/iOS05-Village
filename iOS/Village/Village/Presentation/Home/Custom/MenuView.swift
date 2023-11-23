//
//  MenuView.swift
//  Village
//
//  Created by 정상윤 on 11/16/23.
//

import UIKit

final class MenuView: UIView {
    
    private var menuStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupUI()
    }
    
    func setMenuActions(_ actions: [UIAction]) {
        updateMenuButton(actions: actions)
    }
    
    private func setupUI() {
        self.alpha = 0
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
        self.addSubview(menuStackView)
        setMenuStackViewLayoutConstraint()
    }
    
    private func updateMenuButton(actions: [UIAction]) {
        menuStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        actions.forEach { action in
            var configuration = UIButton.Configuration.plain()
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0)
            let button = UIButton(configuration: configuration, primaryAction: action)
            
            button.setTitle(action.title, for: .normal)
            button.backgroundColor = .grey800
            button.tintColor = .white
            button.contentHorizontalAlignment = .leading
            button.titleLabel?.font = .preferredFont(forTextStyle: .title2)
            
            menuStackView.addArrangedSubview(button)
        }
    }
    
    private func setMenuStackViewLayoutConstraint() {
        NSLayoutConstraint.activate([
            menuStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            menuStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            menuStackView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            menuStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        ])
    }
    
}

// MARK: - Fade In & Out
extension MenuView {
    
    func fadeIn() {
        self.isHidden = false
        UIView.transition(with: self, duration: 0.2) {
            self.alpha = 1
        }
    }
    
    func fadeOut() {
        UIView.transition(with: self, duration: 0.2) {
            self.alpha = 0
        }
    }
    
}
