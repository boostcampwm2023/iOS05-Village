//
//  BlockedUserViewController.swift
//  Village
//
//  Created by 박동재 on 2023/12/04.
//

import UIKit

class BlockedUserViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
    }

}

extension BlockedUserViewController {
    
    private func setUI() {
        setNavigationUI()
    }
    
    private func setNavigationUI() {
        self.navigationItem.title = "차단 관리"
    }
    
}
