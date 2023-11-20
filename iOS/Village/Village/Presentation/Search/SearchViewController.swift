//
//  SearchViewController.swift
//  Village
//
//  Created by 박동재 on 2023/11/20.
//

import UIKit

class SearchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBarUI()
        
        view.backgroundColor = .systemBackground
    }
    
    private func setNavigationBarUI() {
        let arrowLeft = self.navigationItem.makeSFSymbolButton(
            self, action: #selector(backButtonTapped), symbolName: .arrowLeft
        )
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: view.frame.width - 70, height: 0))
        searchBar.placeholder = "검색어를 입력해주세요."
        
        navigationItem.leftBarButtonItem = arrowLeft
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchBar)
    }
    
    @objc private func backButtonTapped() {
        self.dismiss(animated: true)
    }

}
