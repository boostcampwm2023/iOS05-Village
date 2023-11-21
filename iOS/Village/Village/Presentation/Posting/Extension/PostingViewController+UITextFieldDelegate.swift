//
//  PostingViewController+UITextFieldDelegate.swift
//  Village
//
//  Created by 조성민 on 11/21/23.
//

import UIKit

extension PostingViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
