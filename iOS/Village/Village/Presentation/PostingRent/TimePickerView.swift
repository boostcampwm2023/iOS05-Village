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

final class TimePickerView: UIView {

    private let dateTextField: UITextField = {
        let textfield = UITextField()
        textfield.text = "날짜"
        textfield.textAlignment = .center
        textfield.tintColor = .clear
        textfield.setLayer()
        return textfield
    }()
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.locale = Locale(identifier: PickerLocale.korea.rawValue)
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        return datePicker
    }()
    private var selectedDate: String?
    
    private let hourTextField: UITextField = {
        let textfield = UITextField()
        textfield.text = "시간"
        textfield.textAlignment = .center
        textfield.tintColor = .clear
        textfield.setLayer()
        return textfield
    }()
    private let hourPicker = UIPickerView()
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
        var time = formatter.date(from: date + hour)
        
        return time
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
        setDatePicker()
        setHourPicker()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setLayout() {
        dateTextField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dateTextField)
        NSLayoutConstraint.activate([
            dateTextField.leadingAnchor.constraint(equalTo: leadingAnchor),
            dateTextField.centerYAnchor.constraint(equalTo: centerYAnchor),
            dateTextField.widthAnchor.constraint(equalToConstant: 100),
            dateTextField.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        hourTextField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hourTextField)
        NSLayoutConstraint.activate([
            hourTextField.leadingAnchor.constraint(equalTo: dateTextField.trailingAnchor, constant: 10),
            hourTextField.centerYAnchor.constraint(equalTo: centerYAnchor),
            hourTextField.widthAnchor.constraint(equalToConstant: 100),
            hourTextField.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    private func setDatePicker() {
        let toolBar = UIToolbar()
        let flexibleSpace = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        let doneButton = UIBarButtonItem(
            barButtonSystemItem: .done, 
            target: self,
            action: #selector(datePickerDoneTapped)
        )

        toolBar.items = [flexibleSpace, doneButton]
        toolBar.sizeToFit()

        dateTextField.inputAccessoryView = toolBar
        dateTextField.inputView = datePicker
    }
    
    private func setHourPicker() {
        hourPicker.delegate = self
        hourPicker.dataSource = self
        
        let toolBar = UIToolbar()
        let flexibleSpace = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        let doneButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(hourPickerDoneTapped)
        )

        toolBar.items = [flexibleSpace, doneButton]
        toolBar.sizeToFit()

        hourTextField.inputAccessoryView = toolBar
        hourTextField.inputView = hourPicker
    }
    
    @objc func datePickerDoneTapped(_ sender: UIBarButtonItem) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        formatter.locale = Locale(identifier: PickerLocale.korea.rawValue)
        selectedDate = formatter.string(from: datePicker.date)
        dateTextField.text = formatter.string(from: datePicker.date)
        dateTextField.resignFirstResponder()
    }
    
    @objc func hourPickerDoneTapped(_ sender: UIBarButtonItem) {
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
