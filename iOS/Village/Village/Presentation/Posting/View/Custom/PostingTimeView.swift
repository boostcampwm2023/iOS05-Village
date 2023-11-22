//
//  PostingTimeView.swift
//  Village
//
//  Created by 조성민 on 11/22/23.
//

import UIKit

enum TimeType {
    
    case start
    case end
    
}

class PostingTimeView: UIStackView {

    private let postType: PostType
    private let timeType: TimeType
    
    private lazy var timeHeaderLabel: UILabel = {
        let label = UILabel()
        switch postType {
        case .rent:
            label.text = "대여 시작 가능"
        case .request:
            label.text = "대여 시작"
        }
        label.font = .boldSystemFont(ofSize: 16)
        
        return label
    }()
    
    private let startTimePicker: TimePickerView = {
        let picker = TimePickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        
        return picker
    }()
    
    private let startTimeWarningLabel: UILabel = {
        let label = UILabel()
        label.text = "시간을 선택해야 합니다."
        label.font = .systemFont(ofSize: 14)
        label.textColor = .negative400
        label.alpha = 0
        
        return label
    }()
    
    private var isEmptyStartTime: Bool {
        if startTimePicker.time == nil {
            return true
        }
        return false
    }
    
    init(postType: PostType, timeType: TimeType) {
        self.postType = postType
        self.timeType = timeType
        super.init(frame: .zero)
        setUp()
        configureUI()
        configureConstraints()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension PostingTimeView {
    
    func setUp() {
        spacing = 10
        axis = .vertical
    }
    
    func configureUI() {
        addArrangedSubview(timeHeaderLabel)
        addArrangedSubview(startTimePicker)
        addArrangedSubview(startTimeWarningLabel)
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            startTimePicker.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
}
