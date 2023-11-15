//
//  PeriodPicker.swift
//  Village
//
//  Created by 조성민 on 11/15/23.
//

import UIKit

enum PeriodPickerLocale: String {
    case korea = "ko-KR"
}

enum SegmentedControlIndex: Int {
    case periodStart
    case periodEnd
}

final class PeriodPicker: UIView {
    
    private let startDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: PeriodPickerLocale.korea.rawValue)
        return datePicker
    }()
    private let endDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: PeriodPickerLocale.korea.rawValue)
        return datePicker
    }()
    var startTime: Date?
    var endTime: Date?
    private let segmentedControl: UISegmentedControl
    private var togglePicker: Bool = false {
        didSet {
            startDatePicker.isHidden = togglePicker
            endDatePicker.isHidden = !togglePicker
        }
    }

    init(startSegmentTitle: String, endSegmentTitle: String) {
        segmentedControl = UISegmentedControl(items: [startSegmentTitle, endSegmentTitle])
        super.init(frame: .zero)
        setupView()
        setupSegmentedControl()
        setupDatePicker()
    }
    
    override init(frame: CGRect) {
        segmentedControl = UISegmentedControl(items: ["startPeriodPicker", "endPeriodPicker"])
        super.init(frame: frame)
        setupView()
        setupSegmentedControl()
        setupDatePicker()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        layer.cornerRadius = 8
        layer.borderWidth = 0.5
    }
    
    func setupDatePicker() {
        startDatePicker.translatesAutoresizingMaskIntoConstraints = false
        endDatePicker.translatesAutoresizingMaskIntoConstraints = false
        addSubview(startDatePicker)
        addSubview(endDatePicker)
        startDatePicker.addTarget(self, action: #selector(startDateChanged), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(endDateChanged), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            startDatePicker.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            startDatePicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            startDatePicker.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        NSLayoutConstraint.activate([
            endDatePicker.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            endDatePicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            endDatePicker.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func setupSegmentedControl() {
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.addTarget(self, action: #selector(segmentedControlChange), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControlChange(segment: segmentedControl)
        
        addSubview(segmentedControl)
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: topAnchor),
            segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    @objc func startDateChanged(_ sender: UIDatePicker) {
        startTime = sender.date
    }
    
    @objc func endDateChanged(_ sender: UIDatePicker) {
        endTime = sender.date
    }

    @objc func segmentedControlChange(segment: UISegmentedControl) {
        togglePicker = segment.selectedSegmentIndex != SegmentedControlIndex.periodStart.rawValue
    }
    
}
