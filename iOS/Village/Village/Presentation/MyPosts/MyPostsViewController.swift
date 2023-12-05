//
//  MyPostsViewController.swift
//  Village
//
//  Created by 조성민 on 12/5/23.
//

import UIKit
import Combine

final class MyPostsViewController: UIViewController {
    
    typealias MyPostsDataSource = UITableViewDiffableDataSource<Section, PostListResponseDTO>
    
    typealias ViewModel = MyPostsViewModel
    typealias Input = ViewModel.Input
    
    enum Section: String {
        case request = "요청글"
        case rent = "대여글"
        
        var index: Int {
            switch self {
            case .request:
                return 0
            case .rent:
                return 1
            }
        }
        
        static func toSection(index: Int) -> Section {
            switch index {
            case 0:
                return .request
            default:
                return .rent
            }
        }
    }
    
    private let viewModel: ViewModel
    
    private lazy var dataSource: MyPostsDataSource = MyPostsDataSource(
        tableView: tableView) { [weak self] (tableView, indexPath, post) in
//            guard let self = self else {
//                return RequestPostTableViewCell()
//            }
            if post.isRequest {
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: RequestPostTableViewCell.identifier,
                    for: indexPath) as? RequestPostTableViewCell else {
                    return RequestPostTableViewCell()
                }
                cell.configureData(post: post)
                cell.selectionStyle = .none
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: RentPostTableViewCell.identifier,
                    for: indexPath) as? RentPostTableViewCell else {
                    return RentPostTableViewCell()
                }
                cell.configureData(post: post)
                cell.selectionStyle = .none
                return cell
            }
        }
    
    private lazy var requestSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: [Section.request.rawValue, Section.rent.rawValue])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        control.selectedSegmentIndex = Section.request.index
        control.selectedSegmentTintColor = .primary500
        
        return control
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 80
        tableView.register(RequestPostTableViewCell.self, forCellReuseIdentifier: RequestPostTableViewCell.identifier)
        tableView.register(RentPostTableViewCell.self, forCellReuseIdentifier: RentPostTableViewCell.identifier)
        tableView.separatorStyle = .none
        
        return tableView
    }()
    
    private var cancellableBag = Set<AnyCancellable>()
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViewModel()
        setUI()
        generateData()
    }
    
    @objc private func segmentedControlChanged() {
        toggleData(to: Section.toSection(index: requestSegmentedControl.selectedSegmentIndex))
    }
    
}

private extension MyPostsViewController {
    
    func setViewModel() {
        
    }
    
    func setUI() {
        setNavigationUI()
        
        view.addSubview(requestSegmentedControl)
        view.addSubview(tableView)
        
        view.backgroundColor = .systemBackground
        configureConstraints()
    }
    
    func generateData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PostListResponseDTO>()
        snapshot.appendSections([.request, .rent])
    }
    
    func toggleData(to section: Section) {
        var snapshot = dataSource.snapshot()
        if section == .rent {
            snapshot.appendItems(
                viewModel.rentPosts,
                toSection: section
            )
        } else {
            snapshot.appendItems(
                viewModel.requestPosts,
                toSection: section
            )
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func setNavigationUI() {
        navigationItem.title = "내 게시글"
    }
    
    func configureConstraints() {
        
        NSLayoutConstraint.activate([
            requestSegmentedControl.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10
            ),
            requestSegmentedControl.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10
            ),
            requestSegmentedControl.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10
            ),
            requestSegmentedControl.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10
            ),
            tableView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10
            ),
            tableView.topAnchor.constraint(
                equalTo: requestSegmentedControl.bottomAnchor, constant: 5
            ),
            tableView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 5
            )
        ])
        
    }
    
}
