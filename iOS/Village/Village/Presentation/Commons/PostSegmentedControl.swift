//
//  PostTypeSegmentedControl.swift
//  Village
//
//  Created by 정상윤 on 12/10/23.
//

import UIKit

final class PostSegmentedControl: UIView {
    
    private lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["대여글", "요청글"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 0
        
        return control
    }()
    
    private lazy var underline: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .primary500
        
        return view
    }()
    
    private lazy var underlineLeadingConstraint: NSLayoutConstraint = {
        underline.leftAnchor.constraint(equalTo: leftAnchor)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(segmentedControl)
        addSubview(underline)
        segmentedControl.addTarget(self, action: #selector(changeUnderlinePosition), for: .valueChanged)
        setSegmentedControlUI()
        setLayoutConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = bounds.width / CGFloat(segmentedControl.numberOfSegments)
        let underlineXPosition = width * CGFloat(segmentedControl.selectedSegmentIndex)
        UIView.animate(withDuration: 0.1, animations: { [weak self] in
            self?.underline.frame.origin.x = underlineXPosition
        })
    }
    
    @objc
    private func changeUnderlinePosition() {
        let width = frame.width / CGFloat(segmentedControl.numberOfSegments)
        let leadingDistance = width * CGFloat(segmentedControl.selectedSegmentIndex)
        
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.underlineLeadingConstraint.constant = leadingDistance
            self?.layoutIfNeeded()
        })
    }
    
    private func setSegmentedControlUI() {
        let image = UIImage()
        segmentedControl.setBackgroundImage(image, for: .normal, barMetrics: .default)
        segmentedControl.setBackgroundImage(image, for: .selected, barMetrics: .default)
        segmentedControl.setBackgroundImage(image, for: .highlighted, barMetrics: .default)
        segmentedControl.setDividerImage(image, forLeftSegmentState: .selected,
                                         rightSegmentState: .normal, barMetrics: .default)
        
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.primary500,
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)
        ], for: .selected)
        
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.label,
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)
        ], for: .normal)
    }
    
    private func setLayoutConstraints() {
        NSLayoutConstraint.activate([
            segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor),
            segmentedControl.topAnchor.constraint(equalTo: topAnchor),
            segmentedControl.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            underline.bottomAnchor.constraint(equalTo: bottomAnchor),
            underline.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),
            underline.heightAnchor.constraint(equalToConstant: 2),
            underlineLeadingConstraint
        ])
    }

}
