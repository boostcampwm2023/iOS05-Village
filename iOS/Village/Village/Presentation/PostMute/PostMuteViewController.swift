//
//  PostMuteViewController.swift
//  Village
//
//  Created by 박동재 on 2023/12/04.
//

import UIKit
import Combine

class PostMuteViewController: UIViewController {
    
    typealias PostMuteDataSource = UITableViewDiffableDataSource<Section, PostMuteResponseDTO>
    
    enum Section {
        case mute
    }
    
    private lazy var dataSource: PostMuteDataSource = PostMuteDataSource(
        tableView: postMuteTableView,
        cellProvider: { [weak self] (tableView, indexPath, post) in
            guard let self = self else { return PostMuteTableViewCell() }
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: self.reuseIdentifier,
                for: indexPath) as? PostMuteTableViewCell else {
                return PostMuteTableViewCell()
            }
            cell.configureData(post: post)
            cell.selectionStyle = .none
            return cell
        }
    )
    
    private let reuseIdentifier = ChatRoomTableViewCell.identifier
    private lazy var postMuteTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 80
        tableView.register(PostMuteTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.separatorStyle = .none
        
        return tableView
    }()
    
    private var test: [PostMuteResponseDTO] = []
    private var cancellableBag = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        setTest()
        setUI()
        generateData()
    }

}

private extension PostMuteViewController {
    
    func setTest() {
        guard let path = Bundle.main.path(forResource: "PostMute", ofType: "json") else { return }

        guard let jsonString = try? String(contentsOfFile: path) else { return }
        do {
            let decoder = JSONDecoder()
            let data = jsonString.data(using: .utf8)
            
            guard let data = data else { return }
            let list = try decoder.decode([PostMuteResponseDTO].self, from: data)
            test = list
        } catch {
            return
        }
    }
    
    func setUI() {
        setNavigationUI()
        
        view.addSubview(postMuteTableView)
        
        configureConstraints()
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            postMuteTableView.topAnchor.constraint(equalTo: view.topAnchor),
            postMuteTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            postMuteTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            postMuteTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func setNavigationUI() {
        navigationItem.title = "숨긴 게시물 관리"
    }
    
    func generateData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PostMuteResponseDTO>()
        snapshot.appendSections([.mute])
        snapshot.appendItems(test)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
}
