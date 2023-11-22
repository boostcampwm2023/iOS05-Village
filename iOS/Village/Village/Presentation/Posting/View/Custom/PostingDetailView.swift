//
//  PostingDetailView.swift
//  Village
//
//  Created by 조성민 on 11/22/23.
//

import UIKit

class PostingDetailView: UIStackView {
    
    private let detailHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "자세한 설명"
        label.font = .boldSystemFont(ofSize: 16)
        
        return label
    }()
    
    private lazy var detailTextView: UITextView = {
        let textView = UITextView()
        textView.setLayer()
        textView.textContainerInset = .init(top: 12, left: 12, bottom: 12, right: 12)
        textView.text = "설명을 입력하세요."
        textView.textColor = .lightGray
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.isScrollEnabled = false
        textView.inputAccessoryView = keyboardToolBar
        textView.delegate = self
        
        return textView
    }()
    
    private lazy var keyboardToolBar: UIToolbar = {
        let toolbar = UIToolbar()
        let hideKeyboardButton = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: nil,
            action: #selector(hideKeyboard)
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
        configureUI()
        configureConstraints()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func hideKeyboard(_ sender: UIBarButtonItem) {
        endEditing(true)
    }
    
}

private extension PostingDetailView {
    
    func setUp() {
        spacing = 10
        axis = .vertical
    }
    
    func configureUI() {
        addArrangedSubview(detailHeaderLabel)
        addArrangedSubview(detailTextView)
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            detailTextView.heightAnchor.constraint(equalToConstant: 180)
        ])
    }
    
}

extension PostingDetailView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { (constraint) in
            if estimatedSize.height > 180 && constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "설명을 입력하세요." {
            textView.text = nil
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = "설명을 입력하세요."
            textView.textColor = .lightGray
        }
    }
    
}
