//
//  TimePickerView.swift
//  Village
//
//  Created by 조성민 on 11/17/23.
//

import UIKit

enum PickerLocale: String {
    case korea = "ko-KR"
}

// TODO: 키보드 올리기, 시간 범위
final class TimePickerView: UIView {
    
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.locale = Locale(identifier: PickerLocale.korea.rawValue)
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        return datePicker
    }()
    
    private lazy var dateToolBar: UIToolbar = {
        let toolbar = UIToolbar()
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
    
    private lazy var dateTextField: UITextField = {
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.setLayer()
        textfield.text = "날짜"
        textfield.textAlignment = .center
        textfield.tintColor = .clear
        
        textfield.inputView = datePicker
        textfield.inputAccessoryView = dateToolBar
        
        return textfield
    }()
    
    private lazy var hourPicker: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        
        return pickerView
    }()
    
    private lazy var hourToolBar: UIToolbar = {
        let toolbar = UIToolbar()
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
    
    private lazy var hourTextField: UITextField = {
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.setLayer()
        textfield.text = "시간"
        textfield.textAlignment = .center
        textfield.tintColor = .clear
        
        textfield.inputView = hourPicker
        textfield.inputAccessoryView = hourToolBar
        
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
    var time: Date? {
        guard let date = selectedDate, let hour = selectedHour else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.ddHH:mm"
        formatter.locale = Locale(identifier: PickerLocale.korea.rawValue)
        
        return formatter.date(from: date + hour)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension TimePickerView {
    
    func configureUI() {
        addSubview(dateTextField)
        addSubview(hourTextField)
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            dateTextField.leadingAnchor.constraint(equalTo: leadingAnchor),
            dateTextField.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -10),
            dateTextField.centerYAnchor.constraint(equalTo: centerYAnchor),
            dateTextField.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        NSLayoutConstraint.activate([
            hourTextField.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 10),
            hourTextField.trailingAnchor.constraint(equalTo: trailingAnchor),
            hourTextField.centerYAnchor.constraint(equalTo: centerYAnchor),
            hourTextField.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
}

@objc
private extension TimePickerView {
    
    func datePickerDoneTapped(_ sender: UIBarButtonItem) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        formatter.locale = Locale(identifier: PickerLocale.korea.rawValue)
        selectedDate = formatter.string(from: datePicker.date)
        dateTextField.text = formatter.string(from: datePicker.date)
        dateTextField.resignFirstResponder()
    }
    
    func hourPickerDoneTapped(_ sender: UIBarButtonItem) {
        if selectedHour == nil {
            selectedHour = hours[0]
        }
        hourTextField.text = selectedHour
        hourTextField.resignFirstResponder()
    }
    
}

extension TimePickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    
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
