//
//  SearchViewController.swift
//  Village
//
//  Created by 박동재 on 2023/11/20.
//

import UIKit

class SearchViewController: UIViewController {
    
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBarUI()
        
        view.backgroundColor = .systemBackground
    }
    
    private func setNavigationBarUI() {
        searchController.searchBar.placeholder = "검색어를 입력해주세요."
        searchController.searchBar.frame = CGRect(x: 0, y: 0, width: view.frame.width - 70, height: 0)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchController.searchBar)
        navigationItem.backButtonDisplayMode = .minimal
        navigationItem.hidesSearchBarWhenScrolling = false

    }

}

extension SearchViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        dump(searchController.searchBar.text)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = self.searchController.searchBar.text else { return }
        self.navigationController?.pushViewController(SearchResultViewController(), animated: true)
    }
    
}
