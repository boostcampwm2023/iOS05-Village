//
//  PostCreateTimeView.swift
//  Village
//
//  Created by 조성민 on 11/22/23.
//

import UIKit
import Combine

enum TimeType {
    
    case start
    case end
    
}

enum PickerLocale: String {
    case korea = "ko-KR"
}

final class PostCreateTimeView: UIStackView {
    
    private let timeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        
        return stackView
    }()
    
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.locale = Locale(identifier: PickerLocale.korea.rawValue)
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        return datePicker
    }()
    
    private lazy var dateToolBar: UIToolbar = {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 35))
        let hideKeyboardButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: nil,
            action: #selector(datePickerDoneTapped)
        )
        let flexibleSpaceButton = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        toolbar.sizeToFit()
        toolbar.setItems([flexibleSpaceButton, hideKeyboardButton], animated: false)
        toolbar.tintColor = .label
        
        return toolbar
    }()
    
    lazy var dateTextField: UITextField = {
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.setLayer()
        textfield.text = "날짜"
        textfield.textAlignment = .center
        textfield.tintColor = .clear
        
        textfield.inputView = datePicker
        textfield.inputAccessoryView = dateToolBar
        textfield.delegate = self
        
        return textfield
    }()
    
    private lazy var hourPicker: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        
        return pickerView
    }()
    
    private lazy var hourToolBar: UIToolbar = {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 35))
        let hideKeyboardButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: nil,
            action: #selector(hourPickerDoneTapped)
        )
        let flexibleSpaceButton = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        toolbar.sizeToFit()
        toolbar.setItems([flexibleSpaceButton, hideKeyboardButton], animated: false)
        toolbar.tintColor = .label
        
        return toolbar
    }()
    
    lazy var hourTextField: UITextField = {
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.setLayer()
        textfield.text = "시간"
        textfield.textAlignment = .center
        textfield.tintColor = .clear
        
        textfield.inputView = hourPicker
        textfield.inputAccessoryView = hourToolBar
        textfield.delegate = self
        
        return textfield
    }()
    
    private var selectedDate: String?
    private var selectedHour: String?
    private let hours = [
        "00:00", "01:00", "02:00", "03:00", "04:00", "05:00",
        "06:00", "07:00", "08:00", "09:00", "10:00", "11:00",
        "12:00", "13:00", "14:00", "15:00", "16:00", "17:00",
        "18:00", "19:00", "20:00", "21:00", "22:00", "23:00"
    ]
    var time: Date?
    var timeString: String {
        guard let date = selectedDate,
              let hour = selectedHour else { return "" }
        return date + " " + hour
    }
    
    private let isRequest: Bool
    private let timeType: TimeType
    
    private lazy var timeHeaderLabel: UILabel = {
        let label = UILabel()
        
        switch timeType {
        case .start:
            if isRequest {
                label.text = "대여 시작"
            } else {
                label.text = "대여 시작 가능"
            }
        case .end:
            label.text = "대여 종료"
        }
        
        label.font = .boldSystemFont(ofSize: 16)
        
        return label
    }()
    
    private let timeWarningLabel: UILabel = {
        let label = UILabel()
        label.text = "시간을 선택해야 합니다."
        label.font = .systemFont(ofSize: 14)
        label.textColor = .negative400
        label.alpha = 0
        
        return label
    }()
    
    init(isRequest: Bool, timeType: TimeType) {
        self.isRequest = isRequest
        self.timeType = timeType
        super.init(frame: .zero)
        setUp()
        configureUI()
        configureConstraints()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func warn(_ enable: Bool) {
        let alpha: CGFloat = enable ? 1 : 0
        timeWarningLabel.alpha = alpha
    }
    
    func setEdit(time: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        guard var timeDate = dateFormatter.date(from: time) else { return }
        timeDate -= 540 * 60
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: timeDate)
        dateFormatter.dateFormat = "HH:mm"
        let hourString = dateFormatter.string(from: timeDate)
        
        selectedDate = dateString
        selectedHour = hourString
        datePicker.date = timeDate
        
        guard let hourIndex = hours.firstIndex(of: hourString) else { return }
        hourPicker.selectRow(hourIndex, inComponent: 0, animated: false)
        dateTextField.text = dateString
        hourTextField.text = hourString
        setTime()
    }
    
}

private extension PostCreateTimeView {
    
    func setUp() {
        spacing = 10
        axis = .vertical
    }
    
    func configureUI() {
        timeStackView.addArrangedSubview(dateTextField)
        timeStackView.addArrangedSubview(hourTextField)
        
        addArrangedSubview(timeHeaderLabel)
        addArrangedSubview(timeStackView)
        addArrangedSubview(timeWarningLabel)
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            dateTextField.heightAnchor.constraint(equalToConstant: 48),
            hourTextField.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    func setTime() {
        guard let date = selectedDate, let hour = selectedHour else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.ddHH:mm"
        formatter.locale = Locale(identifier: PickerLocale.korea.rawValue)
        
        time = formatter.date(from: date + hour)
    }
    
}

@objc
private extension PostCreateTimeView {
    
    func datePickerDoneTapped(_ sender: UIBarButtonItem) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        formatter.locale = Locale(identifier: PickerLocale.korea.rawValue)
        selectedDate = formatter.string(from: datePicker.date)
        dateTextField.text = formatter.string(from: datePicker.date)
        dateTextField.resignFirstResponder()
        
        setTime()
        
        if time != nil {
            timeWarningLabel.alpha = 0
        }
    }
    
    func hourPickerDoneTapped(_ sender: UIBarButtonItem) {
        if selectedHour == nil {
            selectedHour = hours[0]
        }
        hourTextField.text = selectedHour
        hourTextField.resignFirstResponder()
        
        setTime()
        
        if time != nil {
            timeWarningLabel.alpha = 0
        }
    }
    
}

extension PostCreateTimeView: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return hours.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return hours[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedHour = hours[row]
    }
    
}

extension PostCreateTimeView: UITextFieldDelegate {
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        return false
    }
    
}
