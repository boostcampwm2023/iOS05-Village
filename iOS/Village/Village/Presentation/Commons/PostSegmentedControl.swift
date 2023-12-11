//
//  PostTypeSegmentedControl.swift
//  Village
//
//  Created by 정상윤 on 12/10/23.
//

import UIKit

final class PostSegmentedControl: UISegmentedControl {
    
    private lazy var underline: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .primary500
        
        return view
    }()
    
    private lazy var underlineLeadingConstraint: NSLayoutConstraint = {
        underline.leadingAnchor.constraint(equalTo: leadingAnchor)
    }()
    
    override init(items: [Any]?) {
        super.init(items: items)
        
        addSubview(underline)
        setSegmentedControlUI()
        setLayoutConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let leadingDistance = (frame.width / CGFloat(numberOfSegments)) * CGFloat(selectedSegmentIndex)
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.underlineLeadingConstraint.constant = leadingDistance
            self?.layoutIfNeeded()
        })
    }
    
    private func setSegmentedControlUI() {
        let image = UIImage()
        setBackgroundImage(image, for: .normal, barMetrics: .default)
        setBackgroundImage(image, for: .selected, barMetrics: .default)
        setBackgroundImage(image, for: .highlighted, barMetrics: .default)
        setDividerImage(image, forLeftSegmentState: .selected,
                                         rightSegmentState: .normal, barMetrics: .default)
        
        setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.primary500,
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)
        ], for: .selected)
        
        setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.label,
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)
        ], for: .normal)
    }
    
    private func setLayoutConstraints() {
        NSLayoutConstraint.activate([
            underlineLeadingConstraint,
            underline.bottomAnchor.constraint(equalTo: bottomAnchor),
            underline.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),
            underline.heightAnchor.constraint(equalToConstant: 2)
        ])
    }

}
