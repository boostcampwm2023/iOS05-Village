//
//  SearchResultViewController.swift
//  Village
//
//  Created by 박동재 on 12/9/23.
//

import UIKit
import Combine

final class SearchResultViewController: UIViewController {
    
    typealias SearchResultDataSource = UITableViewDiffableDataSource<Section, PostListResponseDTO>
    typealias ViewModel = SearchResultViewModel
    
    enum Section { case list }
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var viewModel = ViewModel()
    private var titlePublisher = CurrentValueSubject<String, Never>("")
    private let togglePublisher = PassthroughSubject<Void, Never>()
    private let scrollPublisher = PassthroughSubject<Void, Never>()
    private var cancellableBag = Set<AnyCancellable>()
    
    private var postTitle: String = ""
    
    private lazy var requestSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["대여", "요청"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        control.selectedSegmentIndex = 0
        control.selectedSegmentTintColor = .primary500
        
        return control
    }()
    
    private lazy var dataSource = SearchResultDataSource(
        tableView: listTableView) { [weak self] (tableView, indexPath, post) in
            if post.isRequest {
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: SearchRequstTableViewCell.identifier,
                    for: indexPath) as? SearchRequstTableViewCell else {
                    return SearchRequstTableViewCell()
                }
                cell.configureData(post: post)
                cell.selectionStyle = .none
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: SearchRentTableViewCell.identifier,
                    for: indexPath) as? SearchRentTableViewCell else {
                    return SearchRentTableViewCell()
                }
                cell.configureData(post: post)
                cell.selectionStyle = .none
                return cell
            }
        }
    
    private lazy var listTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 100
        tableView.register(SearchRequstTableViewCell.self, forCellReuseIdentifier: SearchRequstTableViewCell.identifier)
        tableView.register(SearchRentTableViewCell.self, forCellReuseIdentifier: SearchRentTableViewCell.identifier)
        tableView.separatorStyle = .none
        tableView.delegate = self
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        definesPresentationContext = true

        setUI()
        generateData()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if postTitle == "" {
            self.requestSegmentedControl.isHidden = true
            self.listTableView.isHidden = true
        }
    }

}

extension SearchResultViewController {
    
    private func setUI() {
        setNavigationBarUI()
        self.view.backgroundColor = .systemBackground
        self.view.addSubview(requestSegmentedControl)
        self.view.addSubview(listTableView)
        
        configureConstraints()
    }
    
    private func setNavigationBarUI() {
        searchController.searchBar.text = self.postTitle
        searchController.searchBar.frame = CGRect(x: 0, y: 0, width: view.frame.width - 70, height: 0)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.automaticallyShowsCancelButton = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchController.searchBar)
        navigationItem.backButtonDisplayMode = .minimal
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            requestSegmentedControl.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            requestSegmentedControl.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            requestSegmentedControl.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10),
            requestSegmentedControl.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        NSLayoutConstraint.activate([
            listTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            listTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            listTableView.topAnchor.constraint(equalTo: requestSegmentedControl.bottomAnchor, constant: 5),
            listTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 5)
        ])
    }
    
    private func bindViewModel() {
        let input = ViewModel.Input(
            postTitle: self.titlePublisher.eraseToAnyPublisher(),
            toggleSubject: self.togglePublisher.eraseToAnyPublisher(),
            scrollEvent: self.scrollPublisher.eraseToAnyPublisher()
        )
        let output = viewModel.transform(input: input)
        
        output.searchResultList.receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    dump(error)
                }
            } receiveValue: { [weak self] postList in
                self?.addGenerateData(list: postList)
            }
            .store(in: &cancellableBag)
    }
    
    private func generateData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PostListResponseDTO>()
        snapshot.appendSections([.list])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func addGenerateData(list: [PostListResponseDTO]) {
        var snapshot = dataSource.snapshot()
        snapshot.appendItems(list, toSection: .list)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    @objc private func segmentedControlChanged() {
        generateData()
        togglePublisher.send()
    }
    
}

extension SearchResultViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > self.listTableView.contentSize.height - 1000 {
            scrollPublisher.send()
        }
    }
    
    func tableView(_ collectionView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let post = dataSource.itemIdentifier(for: indexPath) else { return }
        
        let postDetailVC = PostDetailViewController(postID: post.postID)
        postDetailVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(postDetailVC, animated: true)
    }
    
}

extension SearchResultViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        self.postTitle = searchController.searchBar.text ?? ""
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        generateData()
        titlePublisher.send(self.postTitle)
        self.requestSegmentedControl.isHidden = false
        self.listTableView.isHidden = false
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
       searchController.hidesNavigationBarDuringPresentation = false
       navigationController?.navigationBar.layoutIfNeeded()
    }
    
}
